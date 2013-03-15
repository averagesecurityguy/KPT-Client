# Copyright (c) 2013 ASG Consulting
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#  Redistributions of source code must retain the above copyright notice, this
#  list of conditions and the following disclaimer.
#
#  Redistributions in binary form must reproduce the above copyright notice,
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#
#  Neither the name of ASG Consulting nor the names of its contributors may
#  be used to endorse or promote products derived from this software without
#  specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.

KnownPlainText
==============

These are the client files needed to connect to the KnownPlainText
service. Below is the installation instructions, usage, and a list 
of files included in the repository. You will need to purchase a 
license key to use the service. See https://knownplaintext.co for 
more details. If you have any questions please contact support@knownplaintext.co

Installation
------------

Before you begin you will need to have Python 2.6 or higher installed. 
Python 2.6 is already installed on most modern *nix machines and on 
Mac OS X. If you plan to run the client on Windows you will need to 
install the latest version of Python 2.x, which you can get at 
http://www.python.org/getit/. You will also need to install pip, which 
you can get at http://pypi.python.org/pypi/pip.

1. Install the Requests library: `pip install requests`
2. Clone the repository: `git clone https://github.com/averagesecurityguy/KnownPlainText`
3. Place the license.key file into the cloned directory.
4. Confirm the client works properly: `client.py -p test.pwdump`

If you have any trouble running the client please contact support@knownplaintext.co.

Usage
-----
There are two ways to use the client. The first, is to use the -p option and 
provide a file in PWDUMP format. Each line of the file should be in the following 
format:

    user:id:lm_hash:ntlm_hash:::

If you provide a PWDUMP file then each found password will be matched up to the 
appropriate username. The username information is not sent to the KnownPlainText 
server.

The second way to use the client is to use the -f option and provide a file that 
contains a list of password hashes in the following format:

    ntlm_hash:lm_hash

If you use the -f option, then each found password will be matched up to the 
appropriate ntlm_hash.

### Examples ###
    client.py -p test.pwdump
    client.py -f test.hashes

Files
-----
* `client.py` - The KnownPlainText client tool.
* `oauth.py` - Oauth library used to authenticate to the KnownPlainText service.
* `test.pwdump` - A test file used to make sure the service is working.
* `anonymyze_pwdump.py` - Replaces usernames in the PWDUMP file with generic usernames.
* `kpt.rb` - Metasploit module for KnownPlainText. Must have a working client.
