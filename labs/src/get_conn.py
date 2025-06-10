import urllib.parse
import os
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv
load_dotenv(override=True)

# for help to enable Microsoft Entra ID authentication for Azure Database for PostgreSQL, see:
# https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-configure-sign-in-azure-ad-authentication
def get_connection_uri():

    # Read URI parameters from the environment
    dbhost = os.getenv('POSTGRES_HOST')
    dbname = os.getenv('POSTGRES_DB')
    dbuser = urllib.parse.quote(os.getenv('POSTGRES_USER'))
    sslmode = os.getenv('SSLMODE')
    dbport = os.getenv('POSTGRES_PORT') 

    # Use passwordless authentication via DefaultAzureCredential.
    # IMPORTANT! This code is for demonstration purposes only. DefaultAzureCredential() is invoked on every call.
    # In practice, it's better to persist the credential across calls and reuse it so you can take advantage of token
    # caching and minimize round trips to the identity provider. To learn more, see:
    # https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/identity/azure-identity/TOKEN_CACHING.md 
    credential = DefaultAzureCredential()

    # Call get_token() to get a token from Microsft Entra ID and add it as the password in the URI.
    # Note the requested scope parameter in the call to get_token, "https://ossrdbms-aad.database.windows.net/.default".
    password = credential.get_token("https://ossrdbms-aad.database.windows.net/.default").token
    password_encoded = urllib.parse.quote_plus(password)

    db_uri = f"postgresql://{dbuser}:{password_encoded}@{dbhost}:{dbport}/{dbname}?sslmode={sslmode}"
    print("Connection uri was rertieved successfully.")
    return db_uri

# if __name__ == "__main__":
#     print(get_connection_uri())