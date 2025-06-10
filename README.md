# **AI with Data Advanced Skilling Initiative**

<div align="center">
  <img src="https://raw.githubusercontent.com/mehrsa/AI_with_DB/refs/heads/main/banner_image.png?token=GHSAT0AAAAAADBR4Q3SRXFS735LIIAHF4242CIGHXQ" alt="banner">
</div>

## Prerequisites 

### python requirements

- We will be using Python version **3.11.9** for the sessions. We recommend using pyenv to set python version for your project and then create a virtual environment. Follow below steps of you are not sure how to do this:
1. [One time thing, it will be worth it!]: Install pyenv by following instructions here https://pyenv-win.github.io/pyenv-win/docs/installation.html
    - specially ensure you set the environment variables are added to user path (they guide you in above link on how to do so)
2. Restart your terminal, run below to ensure pyenv is installed: pyenv versions
    - this should give you all python versions you have. If you don't see 3.11.9, install this version by running: **pyenv install 3.11.9**
    - set local version to 3.11.9: **pyenv local 3.11.9**
3. Run one of below scripts to create a virtual environment: 
    - **virtualenv myenv**
    - **python -m venv myenv**
4. Activate the virtual environment:
    - **.\myenv\Scripts\activate**
5. Install all packages in requirements.txt
    - **pip install -r requirements.txt**

### Azure resources
- You need an Azure account with:
  - **Azure OpenAI LLM Service** (GPT-4.1 or GPT-4 deployed). 
  - **Azure OpenAI Embedding Service** (text-embedding-ada-002). 
  - **Azure Database for PostgreSQL** 
  - **Azure Cosmos DB**
