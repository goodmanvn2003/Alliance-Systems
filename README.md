# Alliance CMS v0.1 RC

[Alliance CMS](http://apps.codigobit.info/2012/06/markdown-pad-markdown-textfile-editor.html) is an open-source software and a universal content management system. It allows users to:

* Design and develop web sites much faster
* Transform and consume data from various sources through extensions
* Freely customize development and production environment

The goal is to help developers and users to create multiple websites by using Rails 3 technology in a flash

## How to install

### Prepare your ruby and rails environment

You have to make sure that your computer should run ruby 1.9.3 or above and rails 3.2.13 - 14 since all of the bundled gems were installed, standardized and optimized across core modules and extensions.

The following softwares can help you set up ruby on rails environment quickly

* (Windows/Mac) [RailsInstaller](http://railsinstaller.org/en)

* (Mac) Install [Homebrew](http://brew.sh/) and follow tutorial at this link: [Installing RoR on OS X](http://ruby.about.com/od/rails3tutorial/ss/Installing-Ruby-On-Rails-On-Os-X.htm)

* (Linux) Just follow tutorial at this link: [Installing RoR on Ubuntu/Linux](http://camtyler.com/development/ruby/install-rails-on-linux-mint-14). Other distro may require different way to install it.

### Pull the source code through Mecurial

The easiest way is to use a Mecurial GUI tool like: [SourceTree](http://www.sourcetreeapp.com/) (Windows/Mac)

On Linux (Ubuntu), you can follow these steps to get the source code

* Install mecurial if it's not available in your system by executing the following command:

    `sudo apt-get install mecurial`

* And, using the following command:

    `hg clone https://bitbucket.org/nlkk/alliance-cms`

* Once done, you should have everything you need to develop your own website/application

## How to use

After installing, you must create an account so that you can manage the system.The first account to be signed up becomes the administrator account.

### Management UI:

You can manage "`pages`", "`elements`", "`contents`" - including labels and articles management, "`files`" - uploading files to server, "`configurations`" and "`Users & Roles`". For more information and tutorial, please go to our [wiki](https://www.google.com)

### Development Guide

The structure of elements are broken down into the following categories:

* Page (containing HTML, JS and other elements)
* Template (containing HTML, JS and other elements)
* Element (containing HTML, JS and other elements) => Tag: `[[(name)? &attr1="value1" &attr2="value2"...]]`
* Script (allowing users/developers to execute raw ruby scripts) => Tag: `[[~(name)? &attr1="value1" &attr2="value2"...]]`
* Placeholder (placed in element) => Tag: `[[$(name)]]`
* Labels and articles (language-sensitive) => Tag: `[[@(name)? &category="(label|article)"]]`

You can use them with HTML tags in your template and it also helps you boost your productivity by providing an easy-to-use HTML/JS editor

There are four roles: administrator (managing everything), developer (managing codes, contents and files), content manager (managing contents) and user

### Examples: (...)


## Extensions

There are a couple of extensions that users and developers can choose from. These are the two noticeable extensions:

1. **Podio Integration Plugin (aka. Alliance Podio Plugin)**, which allows users to securely retrieve data from Podio Application (Podio OAuth Authentication is required) through either web services `{host}/ext/podio/...` or syntactical tags defined by the extension developers. You can find out more [here](https://www.google.com)
2. **Database System Integration Plugin (aka. Alliance DBMS Plugin)**, which allows users to manage data sets and securely retrieve them (Internal Authentication is required) through either web services `{host}/ext/dbms/...` or syntactical tags defined by extension developers. You can find out more [here](https://www.google.com)

If you want to contribute to this project or would like to develop some extensions, please feel free to do so and if you need any help, you just contact us. For more information about where to get helps and supports, please check the `Help` section

## Thanks to

Those who develop and maintain:

 * Bootstrap Framework
 * JQuery
 * AngularJS
 * Ruby on Rails, ACL9, Authlogic and Podio team

## Help

If you are stuck or need helps, you can contact us at [issue tracking](https://bitbucket.org/nlkk/alliance-cms/issues?status=new&status=open)
or our [google group](http://www.google.com)

## License
Non-applicable at the moment
=======
Alliance-Systems
================

CMS for speed and efficiency
