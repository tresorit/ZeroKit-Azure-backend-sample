# ZeroKit-Azure-backend-sample
This is a wrapper project around our [nodejs sample backend project](https://github.com/tresorit/ZeroKit-NodeJs-backend-sample) to make the deployment procedure into Azure cloud easier.

The template will deploy a new Azure resource group into your Azure subscription with a web app and an Azure document DB (configured with MongoDb interface). You can choose the SKU sizes before deployment and change them any time later. Unlike our app in the marketplace, this one can be scaled up and also scaled out any time.

## Deploy or visualize complete architecture with a single click	
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgithub.com%2Ftresorit%2FZeroKit-Azure-backend-sample%2Fraw%2Fmaster%2FZeroKitNodejsSampleDeployment%2Fazuredeploy.json" target="_blank"> <img src="http://azuredeploy.net/deploybutton.png"/></a> <a href="http://armviz.io/#/?load=https%3A%2F%2Fgithub.com%2Ftresorit%2FZeroKit-Azure-backend-sample%2Fraw%2Fmaster%2FZeroKitNodejsSampleDeployment%2Fazuredeploy.json" target="_blank"><img src="http://armviz.io/visualizebutton.png"/>
</a>
		
## Prerequisites for deployment

 - You will need a ZeroKit tenant. If you do not have one, you can register a free sandbox tenant at  https://manage.tresorit.io
 - You will  also need an Azure cloud subscription. You can get one for *free** at [azure.com](https://azure.com).

***Warning:** While the registration in Azure is free and a small amount of computation power is also provided for free by Microsoft, any additional resource usage may billed by Microsoft corporation. Tresorit is not responsible in any ways for these charges.
		
## Deployment
After clicking the deploy button (and possibly logging in to your Azure subscription) the Azure portal will show you a similar pre-deployment configuration screen.

<img src="https://github.com/tresorit/ZeroKit-Azure-backend-sample/raw/master/.images/azure-template-deployment.png"/>

- The non-Zkit settings are your choice, they will set the names and allocated sizes of the new resources. (The "Web app name" will became the address of your web application.)
- The "Tenant ID", "Admin key" can be copied from the ZeroKit management portal.
  The tenant id is the first part of your tenant service URL:

<img src="https://github.com/tresorit/ZeroKit-Azure-backend-sample/raw/master/.images/zerokit-tenant-id.png"/>

- The IDP configuration can also be done on the ZeroKit management portal. You can find further information about it in the original [repository of the sample server](https://github.com/tresorit/ZeroKit-NodeJs-backend-sample).

## Configuration after deployment
You can configure your application anytime from the Azure dashboard. Open up the configuration page of your web app and choose "Application settings" tab. You will find there the mapped configuration settings, which are loaded by the config.env.js configurator script in the repository root.

<img src="https://github.com/tresorit/ZeroKit-Azure-backend-sample/raw/master/.images/azure-webapp-config.png"/>

If you need more information about the sample application or its configuration system, you can find it in [the repository of that project](https://github.com/tresorit/ZeroKit-NodeJs-backend-sample).
		
## Project structure:
The project itself is a Visual Studio 2015 solution, with the following structure:

- **.build** (folder): contains the build scripts of the solution
- **ZeroKitNodejsSample** (folder): wrapper project around our nodejs backend sample project from github
  - **.bin** (folder): helper scripts for deployment for non-cloud hosted IIS
  - **.build** (folder): build scripts for the project, used by the global build script
  - **app** (folder): contains the nodejs app as a git submodule from our [github account](https://github.com/tresorit/ZeroKit-NodeJs-backend-sample) 
  - ***config.env.js***: configuration script which imports settings from azure settings (environment variables)
  - ***Package.pubxml***: publish profile for creating deplyoment package
  - ***Web.config***: web configuration for IIS
- **ZeroKitNodejsSampleDeployment** (folder): azure deplyoment project which contains the ARM templates for the deployment system
  - ***azuredeploy.json***: main ARM template
  - ***azuredeploy.parameters.json***: parameter descriptions for the template
  - ***metadata.json***: metadata information for the template
  - ***Deploy-AzureResourceGroup.ps1***: helper script for deployments from command line
  
## Custom build:
If you want to build a deployment package for yourself, because you want to modify the sources or automate installation you can do it after cloning the repository with the following steps:
### Prerequisites:
- build must be done on a windows machine (win 7-8-10)
- installed VS2015 (experimental 2017)
- installed nodejs 6, 7 or 8, npm must be available in path

### Build steps:
1. Check out repository with submodules
2. Make changes if you want (example: change config file)
3. If you are not using Visual Studio 2015 (msbuild toolset v14.0) then please open build.ps1 file with an editor and in the first line change the MSbuild tools version accordingly.
4. Build app outside of Visual Studio from powershell by calling ./build.ps1 from the repository root folder
5. If the build was successful, a new version of the deployment package is copied into the *.package* folder

**Warning:** The project file is re-generated every time the build runs, so if you want to make permanent changes to the ZeroKitNodejsSample project, then you must edit *ZeroKitNodejsSample / .build / ZeroKitNodejsSample.njsproj.template* template project file manually.