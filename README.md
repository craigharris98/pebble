Azure DevOPS pipeline / Terraform to publish a simple python application, returning the request information back to the sender.

Terraform modules commented in the files, in a larger project I would have considered seperating these out from main and using depends_on to ensure correct order of deployment.

References and issues:

Terraform on Fedora
https://developer.hashicorp.com/terraform/cli/install/yum

Azure CLI to get Terraform up on Fedora.
https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=dnf

Azure Functions.
https://github.com/Azure/azure-functions-core-tools/blob/v4.x/README.md#linux

Terraform modules used are commented within the .tf files where relevant.

Issues:

Ran into a problem triggering the pipeline either by commit into my repo branch or manually in the DevOPS web portal, 
as Microsoft have banned the use of "parallel jobs" until you fill out a form for their approval, making testing the IAC rather tricky..

Linux agent - workaround for this. 

I'm running an agent on my home machine for now and added that to the default agent group as there is no limit on self hosting an agent.
In a production environment we would be authorised to use parallel jobs.

https://learn.microsoft.com/en-us/azure/devops/pipelines/licensing/concurrent-jobs?view=azure-devops&tabs=ms-hosted

https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops#check-prerequisites

(Agent is rather broken by default as it uses an old version of openSSL and the .net binary is misconfigured.
Unfortunately I didnt have access to a windows machine over the weekend as I should think the windows port is much more stable, 
running .NET binaries is always going to be painful in Linux)

(When running in CLI export is fine, if I were to port this into systemD or Docker this would be an environment var).

```
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
```

https://github.com/dotnet/core/issues/2186

Linux agent also requires openSSL 1.1 (EOL in 7 months, Microsoft!).

https://fedora.pkgs.org/35/fedora-x86_64/openssl-1.1.1l-2.fc35.x86_64.rpm.html

Fortunately I didnt need to port a specific Python version into my agent when it ran the pipeline as this is a simple app.
If we had, we would need to make sure the build machine has access to the required Python version and probably pip to install requirements.txt

Once running and listening it was able to pick up the job:

```
Enter work folder (press enter for _work) > 
2023-02-05 23:34:15Z: Settings Saved.
[craig@fedora agent]$ ./run.sh 
Scanning for tool capabilities.
Connecting to the server.
2023-02-05 23:49:24Z: Listening for Jobs
2023-02-05 23:49:46Z: Running job: Run any script on any host
2023-02-05 23:51:14Z: Job Run any script on any host completed with result: Succeeded
2023-02-05 23:51:17Z: Running job: Run any script on any host
2023-02-05 23:51:34Z: Job Run any script on any host completed with result: Succeeded
2023-02-06 00:13:17Z: Running job: Run any script on any host
2023-02-06 00:13:43Z: Job Run any script on any host completed with result: Succeeded
```

Output from curl:
```
{"method": "GET", "url": "https://python-dump.azurewebsites.net/api/http-trigger-dump-request?", "headers": {"x-arr-log-id": "8be174f1-9228-4b7d-ada2-e8ff5e7014b1", "client-ip": "10.0.0.5:30826", "x-arr-ssl": "2048|256|CN=Microsoft Azure TLS Issuing CA 05, O=Microsoft Corporation, C=US|CN=*.azurewebsites.net, O=Microsoft Corporation, L=Redmond, S=WA, C=US", "x-forwarded-proto": "https", "accept-encoding": "gzip, deflate, br", "sec-fetch-mode": "navigate", "max-forwards": "9", "disguised-host": "python-dump.azurewebsites.net", "x-forwarded-for": "81.99.34.252:40354", "x-waws-unencoded-url": "/api/http-trigger-dump-request?", "was-default-hostname": "python-dump.azurewebsites.net", "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8", "x-original-url": "/api/http-trigger-dump-request?", "user-agent": "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/109.0", "accept-language": "en-GB,en;q=0.5", "x-site-deployment-id": "python-dump", "sec-fetch-user": "?1", "connection": "keep-alive", "sec-fetch-dest": "document", "sec-fetch-site": "none", "x-appservice-proto": "https", "host": "python-dump.azurewebsites.net", "x-forwarded-tlsversion": "1.2"}, "params": {}, "get_body": ""}
```
