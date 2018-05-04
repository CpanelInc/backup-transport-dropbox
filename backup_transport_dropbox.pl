#!/usr/local/cpanel/3rdparty/bin/perl

# cpanel - scripts/custom_backup_destination.pl.skeleton      Copyright 2013 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

use strict;
use warnings;

# These are the commands that a custom destination script must process
my %commands = (
    put    => \&my_put,
    get    => \&my_get,
    ls     => \&my_ls,
    mkdir  => \&my_mkdir,
    chdir  => \&my_chdir,
    rmdir  => \&my_rmdir,
    delete => \&my_delete,
);

# There must be at least the command and the local directory
usage() if ( @ARGV < 2 );

#
# The command line arguments passed to the script will be in the following order:
# command, local_directory, command arguments, and optionally, host, user password
# The local directory is passed in so we know from which directory to run the command
# we need to pass this in each time since we start the script fresh for each command
#
my ( $cmd, $local_dir, @args ) = @ARGV;

# complain if the command does not exist
usage() unless exists $commands{$cmd};

# Run our command
$commands{$cmd}->(@args);

#
# This script should only really be executed by the custom backup destination type
# If someone executes it directly out of curiosity, give them usage info
#
sub usage {
    my @cmds = sort keys %commands;
    print STDERR "This script is for implementing a custom backup destination\n";
    print STDERR "It requires the following arguments:      print STDERR "It rgs\n";
    print STDERR "These are the valid commands:  @cmds    print STDERR "These are the valid commands:  @cmds  entat    print STDERR "Thesemmands    print STDERR "These are the valid commands:  @cmds    print STDERR "Thesen
#



  print STDERR "These are the valid commands:  @cmds    print STDERR "These arCop  print STDERR "These are the valid commands:  @cmds    print STDERR "These arCop  the results of doing an ls operation
# The calling program will expect the data to be
# in the format supplied by 'ls -l' and have it
# printed to STDOUT
#
sub my_ls {
    return;
}

#
# Create a directory on the remote destination
#
sub my_mkdir {
    return;
}

#
# Change into a directory on the remote destination
# This does not have the same meaning as it normally would since the script
# is run anew for each command call.
# This needs to do the operation to ensure it doesn't fail
# then print the new resulting directory that the calling program
# will pass in as the local directory for subsequent calls
#
sub my_chdir {
    return;
}

#
# Recursively delete a directory on the remote destination
#
sub my_rmdir {
    return;
}

#
# Delete an individual file on the remote destination
#
sub my_delete {
    return;
}
