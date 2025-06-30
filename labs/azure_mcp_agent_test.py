# Copyright (c) Microsoft. All rights reserved.

import asyncio
import os
from semantic_kernel.agents import ChatCompletionAgent, ChatHistoryAgentThread
from semantic_kernel.connectors.ai.open_ai import AzureChatCompletion
from semantic_kernel.connectors.mcp import MCPStdioPlugin
from dotenv import load_dotenv
load_dotenv()
import sys

import warnings
warnings.filterwarnings("ignore", category=ResourceWarning)


async def init_chat():
    # 1. Create the agent
    async with MCPStdioPlugin(
        name="AzurePlugin",
        description="Azure Resources Plugin",
        command="npx",
        load_tools=True,
        args=["-y", "@azure/mcp@latest", "server", "start"]
    ) as azure_plugin:
    
        agent = ChatCompletionAgent(
            service=AzureChatCompletion(),
            name="Agent",
            instructions=(
            "when conencted to postgres resource, just say 'connected to postgres resource'. Do not share any additional information. "
            "You can use provided tools to answer questions about Azure postgres databases. "
            "Do not include resouce group name, username and subscription id when giving answers." ),
            plugins=[azure_plugin],

        )

        init_input = (
            f"connect to postgres resoource with subscription id: {os.getenv('AZURE_SUBSCRIPTION_ID')}, "
            f"and resource group: {os.getenv('AZURE_RESOURCE_GROUP')}, "
            f"and postgres server name: {os.getenv('POSTGRES_SERVER_NAME')}, "
            f"access database named: {os.getenv('POSTGRES_DB')}, "
            "use Azure AD authentication to access the resources using username: "
            f"{os.getenv('POSTGRES_USER')}, "   
        )

        thread: ChatHistoryAgentThread | None = None
        response = await agent.get_response(messages=init_input, thread=thread)
        print(f"# {response.name}: {response} ")
        thread = response.thread
        while True:
            user_input = input("Enter your question (or type 'bye' to exit): ").strip()
            print(f"# User: {user_input} ")
            if user_input.lower() == "bye":
                print("Exiting the conversation.")
                break 
            else:
                response = await agent.get_response(messages=user_input, thread=thread)
                print(f"# {response.name}: {response} ")
                thread = response.thread
        
if __name__ == "__main__":
    try:
        asyncio.run(init_chat())
    finally:
        if sys.platform == "win32":
            sys.stderr = open(os.devnull, "w")