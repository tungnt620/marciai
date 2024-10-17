This project extend from project https://github.com/zenangst/KeyboardCowboy

# MarciAI

## Simplify complex tasks and streamline workflows for Mac users.
 - By using LLM

## Development

To get this up and running, you'll need to have `tuist` installed.

#### Installing tuist 

The easiest way to install tuist is by using Homebew

```fish
brew install tuist 
```

For more information about [tuist](https://tuist.io), refer to the projects README.

#### Setting up a `.env`

Create a new `.env` file in the root folder.
Add the following contents to the `.env`-file.

```fish
APP_NAME=MarciAI
APP_SCHEME=Keyboard-Cowboy
APP_BUNDLE_IDENTIFIER=com.tung.MarciAI
TEAM_ID=XXXXXXXXXX
PACKAGE_DEVELOPMENT=false
```

#### Generating an Xcode project

Simply run the following commands in the root folder of the repository

```fish
tuist install 
tuist generate
```
