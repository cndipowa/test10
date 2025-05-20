from office365.sharepoint.client_context import ClientContext

site_url = "https://yourtenant.sharepoint.com/sites/yoursite"
ctx = ClientContext(site_url).with_user_credentials("user@domain.com", "yourpassword")

list_obj = ctx.web.lists.get_by_title("Your List Name")
items = list_obj.items.get().execute_query()

for item in items:
    print(item.properties)
