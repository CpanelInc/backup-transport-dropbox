# A cPanel custom backup transport for Dropbox
> This script provides a method to automatically upload backups from your cPanel server to Dropbox, utilizing Dropbox's [API](https://www.dropbox.com/developers/documentation) via CPAN [WebService::Dropbox](http://search.cpan.org/~askadna/WebService-Dropbox-0.03/lib/WebService/Dropbox.pm), through the cPanel's [Custom Backup Transport](https://documentation.cpanel.net/display/66Docs/Custom+Backup+Destination+Guide). 

The cPanel backup system provides lots of flexibility, and one of the awesome features is the ability to create custom backup transports. In cPanel, a backup transport is essentially a backup destination or method to move backups to a secondary/remote server for safe keeping. The custom backup transport feature allows you to specify a script which the backup system will pass arguments to; arguments common with uploading files in FTP, e.g. 'put $filename'. Reading over the documentation, it may at first appear a daunting task; however, today we'll walk you through the process by creating a backup destination utilizing Dropbox and their very thoroughly documented API.

Special thanks to [@Tim Mullin](https://github.com/timmullin) for helping me get this off the ground by providing a PoC.

## Requirements
```
cPanel 78+
CPAN WebService::Dropbox
```

## Installation
Install CPAN WebService::Dropbox
```
# CentOS 7
sudo cpan WebService::Dropbox

# CentOS 6
sudo yum -y install perl-YAML
sudo cpan WebService::Dropbox
```
During the CPAN installation for WebService::Dropbox, you may be prompted "*...just needed temporarily during building or testing. Do you want to install it permanently?*" These are relatively small modules and having them installed will help with future CPAN module installations, so I chose "yes" for each prompt.

Download the script
```
# escalate to root
sudo su - root

# clone and copy the script from github
cd /usr/local/src
git clone https://github.com/CpanelInc/backup-transport-dropbox.git
cp -av backup-transport-dropbox/backup_transport_dropbox.pl /usr/local/bin/
```

## Configure
If you don't already have a Dropbox account, create one [here](https://www.dropbox.com/login). Once you have an account, head over to their developer section to [create an app](https://www.dropbox.com/developers/apps/create)(this is required to use their API). You'll be prompted to select the typical *Dropbox API* or the *Business API*. For our testing purposes, we'll stick with the simple/free Dropbox API. For step two of the app creation process, select *Full Dropbox*. Finally, set a name for your app; I chose 'cpanel-backups'.

![Dropbox - Create an App](https://user-images.githubusercontent.com/25645218/39636904-2b13308a-4f87-11e8-8f44-0edcd6d1d92b.png)

After creating the Dropbox app, you'll be redirected to the *Settings* page for your app, which will provide your API credentials. Write down the *App Key*, *App Secret*, click the *Generate access token* button and write it down as well

![Dropbox App Settings](https://user-images.githubusercontent.com/25645218/39636818-eed9ad1a-4f86-11e8-84a9-6f645f9bd9aa.png)

With your favorite text editor, take the Dropbox credentials you saved earlier and update the *MY_APP_KEY*, *MY_APP_SECRET*, and *MY_ACCESS_TOKEN* placeholders in the transport script.

We're now ready to configure the transport in WHM. Head over to *WHM » Backup » Backup Configuration* and scroll down to *Additional Destinations*. Under *Destination Type*, select *Custom*, then *Create new destination*. Configure the destination as below(note, since we're using the API keys directly in the transport script, you can enter anything for the host, user, and password):

![Create the custom backup transport in WHM](https://user-images.githubusercontent.com/25645218/39636767-cb5ab618-4f86-11e8-8bfd-0f4ca46595a8.png)

Be sure to hit *Save and Validate Destination* at the bottom of the screen. 

Congratulations, you've just created your first custom backup transport script, how cool is that?! Feel free to fork us on GitHub and be sure to share with us your custom backup transport scripts!
