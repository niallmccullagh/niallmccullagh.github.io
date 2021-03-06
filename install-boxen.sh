set -e
set -u

# clean up /tmp/install-boxen on exit if we were run like that
if [ "$0" = "/tmp/install-boxen" ]; then
    trap 'rm -f /tmp/install-boxen' EXIT
fi

set +e
OSX_VERSION=`sw_vers | grep ProductVersion | cut -f 2 -d ':'  | awk ' { print $1; } '`

if [ ! $(echo $OSX_VERSION | egrep '10\.8|10\.9') ]; then
    echo 'You must be on Mountain Lion or greater!'
    exit 1
fi
set -e

if [ "$OSX_VERSION" = "10.8" ] && [ ! -f /usr/bin/gcc ]; then
  printf "%s\n" $'

Since you are running OS X 10.8, you will need to install Xcode and the
Command Line Tools to continue.

  1. Go to the App Store and install Xcode.
  2. Start Xcode.
  3. Click on Xcode in the top left corner of the menu bar and click on
     Preferences.
  4. Click on the Downloads tab.
  5. Click on the Install button next to Command Line Tools.'
  exit 1
fi

if [ "$OSX_VERSION" = "10.9" ]; then
  printf "%s\n" $'

Since you are running OS X 10.9, you will need to install the Command
Line Tools.

  1. You should see a pop-up asking you to install them in a moment.
  2. Click Install!'

  until $(gcc -v); do
    sleep 60
  done
fi

# show the banner and wait for a response
printf "%s" $'\e[1;32m
    ########   #######  ##     ## ######## ##    ##
    ##     ## ##     ##  ##   ##  ##       ###   ##
    ##     ## ##     ##   ## ##   ##       ####  ##
    ########  ##     ##    ###    ######   ## ## ##
    ##     ## ##     ##   ## ##   ##       ##  ####
    ##     ## ##     ##  ##   ##  ##       ##   ###
    ########   #######  ##     ## ######## ##    ##\e[1;31m

\e[0m
    Hello! I\'m going to set up this machine for you. It might take me a bit
    of time before I\'m done, but you\'ll end up with a happy machine by the
    end of it.
\e[0;1m
    Ready to get started? Brutalize a key with your favorite finger.\e[0m'
read -n 1 -s

# prompt for sudo access. if correct we're good to go.
echo "

--> For added privacy invasion I'll need your local account's password."
sudo -p "    Password for sudo: " echo "    Sweet, thanks. I'll see you in Vegas, sucker."

echo "
--> Making sure /opt/boxen exists and belongs to you."

sudo mkdir -p /opt/boxen
sudo chown $USER:staff /opt/boxen

if [ ! -f /opt/boxen/repo/.snapshot ]; then
  echo
  echo "--> Grabbing code and extracting. Be patient this may take a while."

  mkdir -p /opt/boxen/repo
  cd /opt/boxen/repo

  curl --progress-bar -L 'https://api.github.com/repos/niallmccullagh/our-boxen/tarball/master' | tar -xz - --strip-components 1 && touch .snapshot
fi

echo "
--> Configuring. Prepare for a long wait and some weird output.
    I might have to ask you for your password again too."

# Make sure sudo hasn't timed out.

sudo -p "    Password for sudo again: "  true

cd /opt/boxen/repo
export BOXEN_REPO_NAME=niallmccullagh/our-boxen
script/boxen

cd $HOME

echo "
You're good to go! Make sure to source /opt/boxen/env.sh in your
shell config if you want all the good stuff to work.
"
