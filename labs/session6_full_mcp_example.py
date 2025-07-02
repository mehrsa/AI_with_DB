# Copyright (c) Microsoft. All rights reserved.

import asyncio
import os
from pathlib import Path

from semantic_kernel.agents import ChatCompletionAgent, ChatHistoryAgentThread
from semantic_kernel.connectors.ai.open_ai import AzureChatCompletion
from semantic_kernel.connectors.mcp import MCPStdioPlugin

from dotenv import load_dotenv
import sys
load_dotenv()

async def main():
    # connect to Azure MCP server
    async with (
        MCPStdioPlugin(
        name="AzurePlugin",
        description="Azure Resources Plugin",
        command="npx",
        load_tools=True,
        args=["-y", "@azure/mcp@latest", "server", "start"]
    ) as azure_plugin,
    # Connect to WriteAgent MCP Plugin
        MCPStdioPlugin(
            name="WriteAgent",
            description="Postgres Write Plugin",
            command=sys.executable,
            args=[
                str(Path(os.path.dirname(__file__)).joinpath("src", "pg_write_mcp.py")),
            ],
            env={
                "AZURE_OPENAI_CHAT_DEPLOYMENT_NAME": os.getenv("AZURE_OPENAI_CHAT_DEPLOYMENT_NAME"),
                "AZURE_OPENAI_ENDPOINT": os.getenv("AZURE_OPENAI_ENDPOINT"),
            },
        ) as write_agent,
    ):
        agent = ChatCompletionAgent(
            service=AzureChatCompletion(),
            name="PersonalAssistant",
            instructions=(
                "You are repsonsible for answering question about the data and adding or removing data."
                                
                f"connect to postgres resoource with subscription id: {os.getenv('AZURE_SUBSCRIPTION_ID')}, "
                f"and resource group: {os.getenv('AZURE_RESOURCE_GROUP')}, "
                f"and postgres server name: {os.getenv('POSTGRES_SERVER_NAME')}, "
                f"access database named: {os.getenv('POSTGRES_DB')}, "
                "use Azure AD authentication to access the resources using username: "
                f"{os.getenv('POSTGRES_USER')}, "   
        )
,
            plugins=[azure_plugin, write_agent],
        )
        thread: ChatHistoryAgentThread | None = None
        while True:
            user_input = input("User: ")
            if user_input.lower() == "exit":
                break
            response = await agent.get_response(messages=user_input, thread=thread)
            print(f"# {response.name}: {response} ")
            thread = response.thread
        await thread.delete() if thread else None



import sys
import os

if __name__ == "__main__":
    try:
        asyncio.run(main())
    finally:
        if sys.platform == "win32":
            sys.stderr = open(os.devnull, "w")