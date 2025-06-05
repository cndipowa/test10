import requests
import yaml
import os
from pathlib import Path
from typing import List, Dict, Optional

class HarnessEntityBatchUploader:
    def __init__(self, account_id: str, api_key: str, base_url: str = "https://app.harness.io/gateway"):
        """
        Initialize the Harness Entity Batch Uploader
        
        Args:
            account_id: Harness account ID
            api_key: Harness API key with appropriate permissions
            base_url: Harness API base URL (defaults to production)
        """
        self.account_id = account_id
        self.api_key = api_key
        self.base_url = base_url
        self.headers = {
            "x-api-key": self.api_key,
            "Content-Type": "application/yaml",
            "Accept": "application/json"
        }
    
    def process_yaml_folder(self, yaml_folder: str = "yaml") -> Dict[str, Dict]:
        """
        Process all YAML files in the specified folder
        
        Args:
            yaml_folder: Path to folder containing YAML files (default: "yaml")
            
        Returns:
            Dictionary with results for each processed file
        """
        results = {}
        yaml_path = Path(yaml_folder)
        
        if not yaml_path.exists():
            raise FileNotFoundError(f"YAML folder not found: {yaml_path}")
        
        print(f"Processing YAML files in: {yaml_path.resolve()}")
        
        # Process each YAML file in the folder
        for yaml_file in yaml_path.glob("*.yaml"):
            try:
                print(f"\nProcessing file: {yaml_file.name}")
                result = self._process_single_yaml(yaml_file)
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
    
    def _process_single_yaml(self, yaml_file: Path) -> Dict:
        """
        Process a single YAML file
        
        Args:
            yaml_file: Path object to the YAML file
            
        Returns:
            API response for the entity
        """
        with open(yaml_file, 'r') as file:
            yaml_content = file.read()
        
        # Parse YAML to get entity metadata
        entity_info = self._parse_yaml_metadata(yaml_content)
        
        # Get appropriate API endpoint
        endpoint = self._get_endpoint_for_entity_type(entity_info["type"])
        if not endpoint:
            raise ValueError(f"Unsupported entity type: {entity_info['type']}")
        
        # Prepare common request parameters
        params = {"accountIdentifier": self.account_id}
        identifier = entity_info["identifier"]
        
        # Determine if entity exists
        entity_exists = self._check_entity_exists(endpoint, identifier, params)
        
        # Make the appropriate API call
        if entity_exists:
            print(f"Updating existing {entity_info['type']}: {identifier}")
            method = "PUT"
            url = f"{self.base_url}{endpoint}/{identifier}"
        else:
            print(f"Creating new {entity_info['type']}: {identifier}")
            method = "POST"
            url = f"{self.base_url}{endpoint}"
        
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
    
    def _parse_yaml_metadata(self, yaml_content: str) -> Dict:
        """
        Parse YAML content to extract entity metadata
        
        Args:
            yaml_content: String containing YAML content
            
        Returns:
            Dictionary with entity metadata (type, identifier)
        """
        try:
            yaml_data = yaml.safe_load(yaml_content)
            if not yaml_data:
                raise ValueError("YAML file is empty or invalid")
                
            entity_type = yaml_data.get("type", "").lower()
            if not entity_type:
                raise ValueError("Could not determine entity type from YAML")
                
            identifier = yaml_data.get("identifier", "")
            if not identifier:
                raise ValueError("Could not determine entity identifier from YAML")
                
            return {
                "type": entity_type,
                "identifier": identifier
            }
        except yaml.YAMLError as e:
            raise ValueError(f"Error parsing YAML: {str(e)}")
    
    def _check_entity_exists(self, endpoint: str, identifier: str, params: Dict) -> bool:
        """
        Check if an entity already exists in Harness
        
        Args:
            endpoint: API endpoint for the entity type
            identifier: Entity identifier
            params: Common request parameters
            
        Returns:
            True if entity exists, False otherwise
        """
        check_url = f"{self.base_url}{endpoint}/{identifier}"
        response = requests.get(
            check_url,
            headers=self.headers,
            params=params
        )
        return response.status_code == 200
    
    def _get_endpoint_for_entity_type(self, entity_type: str) -> Optional[str]:
        """
        Map entity type to API endpoint
        
        Args:
            entity_type: Entity type from YAML
            
        Returns:
            API endpoint path or None if not supported
        """
        endpoints = {
            "pipelines": "/pipeline/api/pipelines/v2",
            "connectors": "/ng/api/connectors",
            "services": "/ng/api/services/v2",
            "environments": "/ng/api/environments/v2",
            "templates": "/template/api/templates",
            "secrets": "/ng/api/v2/secrets",
            "files": "/file-store",
            "users": "/ng/api/user",
            "usergroups": "/ng/api/usergroups",
            "roles": "/authz/api/roles",
            "resourcegroups": "/authz/api/resourcegroups",
            # Add more entity types as needed
        }
        return endpoints.get(entity_type)

def print_results_summary(results: Dict):
    """Print a summary of the processing results"""
    print("\nProcessing Summary:")
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

# Example usage
if __name__ == "__main__":
    # Configuration - replace with your values
    ACCOUNT_ID = "YOUR_HARNESS_ACCOUNT_ID"
    API_KEY = "YOUR_HARNESS_API_KEY"
    YAML_FOLDER = "yaml"  # Default folder name
    
    # Initialize uploader
    uploader = HarnessEntityBatchUploader(
        account_id=ACCOUNT_ID,
        api_key=API_KEY
    )
    
    # Process all YAML files in the folder
    try:
        results = uploader.process_yaml_folder(YAML_FOLDER)
        print_results_summary(results)
    except Exception as e:
        print(f"Fatal error: {str(e)}")
