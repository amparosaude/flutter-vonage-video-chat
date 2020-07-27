# workspace.dev
 Dentro deste repositório estão contidos os seguintes projetos:
- [CORE.API](https://github.com/amparosaude/core.api)
- [CORE.APP](https://github.com/amparosaude/core.app)
- [PORTAL.API](https://github.com/amparosaude/portal.api)
- [PORTAL.APP](https://github.com/amparosaude/portal.app)
- [TRAFFIC.API](https://github.com/amparosaude/traffic.api)
- [TRAFFIC.APP](https://github.com/amparosaude/traffic.app)

 ### Rodando os projetos
 1. #### Clone o repositório
 ```
 git clone --recursive git@github.com:amparosaude/workspace.dev.git
 ```
 
 2. #### Dentro do repositório clonado rode as configurações iniciais
 ###### Este comando faz com que todos os repositórios mudem para a branch MASTER e instale as dependências nos APPs
 ```
 bash initial.settings.sh
 ```
 
 3. #### Rode os projetos utilizando o comando ``` docker-compose up ```

#### OBS
 ###### - Não se esqueça de colocar todas as envs dentro dos projetos, caso contrário não irá funcionar
 ###### - É normal que na primeira vez os dois comando demorem para ser finalizados
