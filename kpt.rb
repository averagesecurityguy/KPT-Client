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

# To use this module create a modules/auxiliary/analyze folder in your ~/.msf4 folder.
# Copy the module into the folder and start msfconsole. Finally, load the module with
# the use command:
#
# use auxiliary/analyze/kpt
#
# You will need to set the KPT_PATH option to the directory that holds the KnownPlainText
# client files.
#
# set KPT_PATH /root/KnownPlainText
#
# Finally, run the module and it will grab all the smb_hashes from the metasploit database,
# write them to a file, and call the KnownPlainText client with the file. Finally, it will
# load back into the database any passwords cracked by KnownPlainText.

require 'msf/core'

class Metasploit3 < Msf::Auxiliary

	include Msf::Auxiliary::Report

	def initialize
		super(
			'Name'		=> 'KnownPlainText.co Password Cracker',
			'Description'       => %Q{
				This module uses the KnownPlainText.co service to identify weak passwords
				that have been acquired as hashed files (loot) or raw LANMAN/NTLM hashes 
				(hashdump). The goal of this module is to find trivial passwords in a short 
				amount of time. To crack complex passwords another password cracking tool
				should be used outside of Metasploit.

				You must have a working copy of the KnownPlainText client including a 
				valid license key for this module to work properly.
			},
			'Author'			=> 'averagesecurityguy',
			'License'			=> MSF_LICENSE
		)

		register_options(
			[
				OptPath.new('KPT_PATH', [false, 'The directory containing the KnownPlainText client']),
			], self.class)
	end

	def run

		# Create a PWDUMP style input file for SMB Hashes
		pwdump = ::File.join( datastore["KPT_PATH"], "metasploit.pwdump")
		hashlist = ::File.open(pwdump, 'wb')
		smb_hashes = myworkspace.creds.select{|x| x.ptype == "smb_hash" }
		smb_hashes.each do |cred|
			hashlist.write( "cred_#{cred[:id]}:#{cred[:id]}:#{cred[:pass]}:::\n" )
		end
		hashlist.close

		# Use KnownPlainText.co to lookup the hashes.
		kpt_exe = ::File.join( datastore["KPT_PATH"], "client.py" )
		cmd = kpt_exe + ' -p ' + hashlist.path
		print_status(cmd)
		::IO.popen(cmd, "rb") do |fd|
			fd.each_line do |line|
				line.chomp!

				# Store the cracked results based on user_id => cred.id
				next if not line =~ /^cred_(\d+):(.*)/m
				cid = $1.to_i
				pass = $2

				cred_find = smb_hashes.select{|x| x[:id] == cid}
				next if cred_find.length == 0
				cred = cred_find.first
				next if cred.user.to_s.strip.length == 0

				print_good("Cracked: #{cred.user}:#{pass} (#{cred.service.host.address}:#{cred.service.port})")
				report_auth_info(
					:host  => cred.service.host,
					:service => cred.service,
					:user  => cred.user,
					:pass  => pass,
					:type  => "password",
					:source_id   => cred[:id],
					:source_type => 'cracked'
				)
			end
		end
	end
end
