import requests
import yaml
import os
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from urllib.parse import urljoin

class HarnessCatalogUploader:
    def __init__(
        self,
        account_id: str,
        api_key: str,
        org_identifier: Optional[str] = None,
        project_identifier: Optional[str] = None,
        base_url: str = "https://app.harness.io/gateway"
    ):
        """
        Initialize the Harness Catalog Uploader
        
        Args:
            account_id: Harness account ID
            api_key: Harness API key with appropriate permissions
            org_identifier: Organization identifier (optional)
            project_identifier: Project identifier (optional)
            base_url: Harness API base URL
        """
        self.account_id = account_id
        self.api_key = api_key
        self.org_identifier = org_identifier
        self.project_identifier = project_identifier
        self.base_url = base_url
        self.headers = {
            "x-api-key": self.api_key,
            "Content-Type": "application/yaml",
            "Accept": "application/json"
        }
    
    def process_catalog_folder(self, yaml_folder: str = "catalog") -> Dict[str, Dict]:
        """
        Process all YAML files in the specified catalog folder
        
        Args:
            yaml_folder: Path to folder containing catalog YAML files
            
        Returns:
            Dictionary with results for each processed file
        """
        results = {}
        yaml_path = Path(yaml_folder)
        
        if not yaml_path.exists():
            raise FileNotFoundError(f"Catalog folder not found: {yaml_path}")
        
        print(f"Processing catalog YAML files in: {yaml_path.resolve()}")
        
        for yaml_file in yaml_path.glob("*.yaml"):
            try:
                print(f"\nProcessing file: {yaml_file.name}")
                result = self._process_catalog_yaml(yaml_file)
                results[yaml_file.name] = {
                    "status": "success",
                    "result": result
                }
            except Exception as e:
                results[yaml_file.name] = {
                    "status": "error",
                    "error": str(e)
                }
                print(f"Error processing {yaml_file.name}: {str(e)}")
        
        return results
    
    def _process_catalog_yaml(self, yaml_file: Path) -> Dict:
        """
        Process a single catalog YAML file
        
        Args:
            yaml_file: Path to the YAML file
            
        Returns:
            API response for the catalog entity
        """
        with open(yaml_file, 'r') as file:
            yaml_content = file.read()
        
        # Parse YAML to get catalog metadata
        catalog_metadata = self._parse_catalog_yaml(yaml_content)
        kind = catalog_metadata["kind"]
        identifier = catalog_metadata["identifier"]
        
        # Get API endpoint for this kind
        endpoint = self._get_endpoint_for_kind(kind)
        if not endpoint:
            raise ValueError(f"Unsupported catalog kind: {kind}")
        
        # Prepare common request parameters
        params = {
            "accountIdentifier": self.account_id,
            "orgIdentifier": self.org_identifier,
            "projectIdentifier": self.project_identifier
        }
        
        # Clean None values from params
        params = {k: v for k, v in params.items() if v is not None}
        
        # Check if entity exists by trying to get it
        entity_exists = self._check_entity_exists(endpoint, identifier, params)
        
        # Make the appropriate API call
        if entity_exists:
            print(f"Updating existing {kind}: {identifier}")
            method = "PUT"
            url = urljoin(self.base_url, f"{endpoint}/{identifier}")
        else:
            print(f"Creating new {kind}: {identifier}")
            method = "POST"
            url = urljoin(self.base_url, endpoint)
        
        response = requests.request(
            method,
            url,
            headers=self.headers,
            params=params,
            data=yaml_content
        )
        
        if response.status_code not in [200, 201]:
            raise Exception(f"API request failed. Status: {response.status_code}, Response: {response.text}")
        
        return response.json()
    
    def _parse_catalog_yaml(self, yaml_content: str) -> Dict:
        """
        Parse catalog YAML content to extract metadata
        
        Args:
            yaml_content: String containing YAML content
            
        Returns:
            Dictionary with catalog metadata (kind, identifier)
        """
        try:
            yaml_data = yaml.safe_load(yaml_content)
            if not yaml_data:
                raise ValueError("YAML file is empty or invalid")
                
            kind = yaml_data.get("kind", "").lower()
            if not kind:
                raise ValueError("Could not determine 'kind' from YAML")
                
            # For catalog entities, identifier might not be in the root
            # Try to get it from metadata or spec
            identifier = (
                yaml_data.get("metadata", {}).get("identifier") or
                yaml_data.get("spec", {}).get("identifier")
            )
            if not identifier:
                raise ValueError("Could not determine entity identifier from YAML")
                
            return {
                "kind": kind,
                "identifier": identifier
            }
        except yaml.YAMLError as e:
            raise ValueError(f"Error parsing YAML: {str(e)}")
    
    def _check_entity_exists(self, endpoint: str, identifier: str, params: Dict) -> bool:
        """
        Check if a catalog entity already exists
        
        Args:
            endpoint: API endpoint for the entity kind
            identifier: Entity identifier
            params: Request parameters
            
        Returns:
            True if entity exists, False otherwise
        """
        check_url = urljoin(self.base_url, f"{endpoint}/{identifier}")
        response = requests.get(
            check_url,
            headers=self.headers,
            params=params
        )
        return response.status_code == 200
    
    def _get_endpoint_for_kind(self, kind: str) -> Optional[str]:
        """
        Map catalog kind to API endpoint
        
        Args:
            kind: Catalog entity kind from YAML
            
        Returns:
            API endpoint path or None if not supported
        """
        endpoints = {
            "component": "/catalog/api/entities",
            "resource": "/catalog/api/entities",
            "api": "/catalog/api/entities",
            "template": "/catalog/api/entities",
            "user": "/catalog/api/entities",
            "system": "/catalog/api/entities",
            # Add more catalog kinds as needed
        }
        return endpoints.get(kind)

def print_upload_summary(results: Dict):
    """Print a summary of the upload results"""
    print("\nUpload Summary:")
    print("=" * 50)
    
    success_count = sum(1 for r in results.values() if r["status"] == "success")
    error_count = len(results) - success_count
    
    print(f"Total files processed: {len(results)}")
    print(f"Successful: {success_count}")
    print(f"Errors: {error_count}")
    
    if error_count > 0:
        print("\nFiles with errors:")
        for file_name, result in results.items():
            if result["status"] == "error":
                print(f"- {file_name}: {result['error']}")

if __name__ == "__main__":
    # Configuration - replace with your values
    CONFIG = {
        "account_id": "YOUR_HARNESS_ACCOUNT_ID",
        "api_key": "YOUR_HARNESS_API_KEY",
        "org_identifier": "YOUR_ORG_ID",  # Optional
        "project_identifier": "YOUR_PROJECT_ID",  # Optional
        "catalog_folder": "catalog"  # Default folder name
    }
    
    # Initialize uploader
    uploader = HarnessCatalogUploader(
        account_id=CONFIG["account_id"],
        api_key=CONFIG["api_key"],
        org_identifier=CONFIG.get("org_identifier"),
        project_identifier=CONFIG.get("project_identifier")
    )
    
    # Process all catalog YAML files
    try:
        results = uploader.process_catalog_folder(CONFIG["catalog_folder"])
        print_upload_summary(results)
    except Exception as e:
        print(f"Fatal error: {str(e)}")
