# ...existing code...

# Remove all VectorStore, VectorStoreRecordCollection, and related CosmosDB vector store logic.
# Use a simple Cosmos DB container for storing chat history as documents.

from azure.cosmos import CosmosClient
import os
import json

# Remove ChatHistoryModel, VectorStore, and related dataclasses

class ChatHistoryInCosmosDB(ChatHistory):
    """This class stores the chat history in a Cosmos DB container as plain documents."""

    def __init__(self, session_id: str, user_id: str, container):
        super().__init__()
        self.session_id = session_id
        self.user_id = user_id
        self.container = container

    async def store_messages(self):
        """Store the chat history in the Cosmos DB as a document."""
        item = {
            "id": self.session_id,
            "user_id": self.user_id,
            "messages": [msg.model_dump() for msg in self.messages],
        }
        self.container.upsert_item(item)

    async def read_messages(self):
        """Read the chat history from the Cosmos DB."""
        try:
            item = self.container.read_item(item=self.session_id, partition_key=self.user_id)
            self.messages = [ChatMessageContent.model_validate(m) for m in item.get("messages", [])]
        except Exception:
            self.messages = []

# ...existing code...

async def main() -> None:
    session_id = "session1"
    chatting = True

    # Setup Cosmos DB client and container
    endpoint = os.getenv("COSMOS_ENDPOINT")
    key = os.getenv("COSMOS_KEY")
    database_name = os.getenv("COSMOS_DATABASE", "ABC")
    container_name = os.getenv("COSMOS_CONTAINER", "chat_history")

    client = CosmosClient(endpoint, key)
    database = client.get_database_client(database_name)
    container = database.get_container_client(container_name)

    # Create chat history object
    history = ChatHistoryInCosmosDB(session_id=session_id, user_id="user", container=container)

    print(
        "Welcome to the chat bot!\n"
        "  Type 'exit' to exit.\n"
        "  Try a math question to see function calling in action (e.g. 'what is 3+3?')."
    )
    try:
        while chatting:
            chatting = await chat(history)
    except Exception:
        print("Closing chat...")

if __name__ == "__main__":
    asyncio.run(main())