## inDev



An easy to use Wrapper for running commands within specified containers 



- Reproducible builds (every developer uses the same environments)

- Never install dependencies manually

- Cleaner Development & Host Environments as tools are used within containers
- Just add `inDev.yaml` config to your project and fire up a dev environment tailored to that project almost instantly



###### Installation:

* Download the Latest Release [Releases](https://github.com/SvalTek/inDev/releases)
* Copy inDev.exe to someplace in your systems path

###### Usage:

`inDev %CD% help ` - show the inDev usage info
`inDev %CD% run [command] [args]` - run a command using inDev, replacing [command] with your command and [args] with any parameters

Examples:

> regular:
>
>  `docker run  --mount type=bind,src=%CD%,dst=/opt/workspace -w /opt/workspace -i -t alpine:latest sh -c ls -l && whoami`
>
> inDev:
>
>  `inDev %CD% run sh -c "ls -l && whoami"`
>
> regular:
>
>  `docker run --mount type=bind,src=%CD%,dst=/opt/workspace -w /opt/workspace -i -t docker.io/node:12-alpine npm install -g npx`
>
> inDev:
>
>  `inDev %CD% run npm install -g npx`

* By default inDev provides two pre-configured environments, these can be used system wide and will bind-mount

  the current directory (passed as first parameter to inDev) as /opt/workspace and set that as the containers working directory

  * shell: latest official alpine image used to run commands:
    * sh | bash | zsh
  * node: latest official alpine Node.js image used to run commands:
    * node | npm | npx | yarn

* these default configurations can be overridden partially or entirely by including them in your local `inDev.yaml`



###### Configuration:

For best use of inDev you'll need to add a configuration to the root of your project or the folder you want to run commands from.

the default configuration is included below as reference,  all properties are required, with the exception of when you are overriding one of the below defaults, in that case you only need provide the properties you are changing.

```yaml
environments:
  - name: shell #name of this environment
    image: alpine:latest # docker image to use
    description: default shell environment # description used only for your reference here currently
    workdir: /opt/workspace # containers working directory
    provides: # list of commands this environment provides
      - sh
      - bash
      - zsh
    bindmounts: # list of folders to make available to the container
      -- # these keys are unnamed. delimit them with --
        source: '%CD%' # the source folder to mount - should be a full windows path
        target: '/opt/workspace' # where to mount this folder in the container - use unix paths

  - name: node
    image: docker.io/node:12-alpine
    description: nodejs environment
    workdir: /opt/workspace
    provides:
      - node
      - npm
      - npx
      - yarn
    bindmounts:
      --
        source: '%CD%'
        target: '/opt/workspace'
```





###### Building

this projects made entirely in Lua,  making use of luvit's luvi tool to produce an executable,

that make this easy to modify and real easy to build...
to build this you need a few things:

- luvi (either somewhere in your path or just place the file in the main folder next to build.bat)
  - used to bundle inDevs lua code into a nice little application
- ResourceHacker.exe (just the executable alone from the zip provided on the website, place it in main folder next to build.bat)
  - used to update the resource data in he built inDev  binary  as luvi doesn't handle any of that itself
- a good Lua ide (preferably vscode just because thats what its made in. but anything works)

Building the project is done by first editing `./versionInfo.rc ` updating versions and any other properties like application description, copyright etc.

then you can just run `build.bat` and you should get a working inDev binary in the build folder

