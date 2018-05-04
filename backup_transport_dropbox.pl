#!/usr/local/cpanel/3rdparty/bin/perl

# cpanel - scripts/custom_backup_destination.pl.skeleton      Copyright 2013 cPanel, Inc.
#                                                           All rights Reserved.
# copyright@cpanel.net                                         http://cpanel.net
# This code is subject to the cPanel license. Unauthorized copying is prohibited

BEGIN {
    unshift @INC, '/usr/local/share/perl5/';
}

use strict;
use warnings;
use IO::File;
use WebService::Dropbox;

our $VERSION = '1.0';

# Create and setup our dropbox object
my $dropbox = WebService::Dropbox->new({
        key =>    'MY_APP_KEY',       # App Key
        secret => 'MY_APP_SECRET'     # App Secret
    });
$dropbox->access_token('MY_ACCESS_TOKEN');

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
    print STDERR "It requires the following arguments:  cmd, local_dir, cmd_args\n";
    print STDERR "These are the valid commands:  @cmds\n";
    exit 1;
}

#
# Relative paths are under $local_dir
#
sub convert_path {
    my ($path) = @_;

    return '' if $path eq '/';
    $path = $1 if ( $path  =~ s|(.+)/\z|| );

    if ( $path =~ m|^/| ) {
        return $path;
    }
    else {
        return File::Spec->catdir( $local_dir, $path );
    }
}

#
# This portion contains the implementations for the various commands
# that the script needs to support in order to implement a custom destination
#

#
# Copy a local file to a remote destination
#
sub my_put {
    my ( $local, $remote, $host, $user, $password ) = @_;
    my $optional_params = { 'mode' => 'overwrite' };

    $remote = convert_path($remote);

    my $fh_upload = IO::File->new($local);

    $dropbox->upload( $remote, $fh_upload, $optional_params ) or die $dropbox->error;

    $fh_upload->close;

    return;
}

#
# Copy a remote file to a local destination
#
sub my_get {
    my ( $remote, $local, $host, $user, $password ) = @_;

    $remote = convert_path($remote);

    my $fh = IO::File->new($local, '>');

    $dropbox->download($remote, $fh);

    $fh->close;

    return;
}

#
# Print out the results of doing an ls operation
# The calling program will expect the data to be
# in the format supplied by 'ls -l' and have it
# printed to STDOUT
#
sub my_ls {
    my ( $path, $host, $user, $password ) = @_;

    $path = convert_path($path);

    my %contents;

    my $result = $dropbox->list_folder($path);

    while($result) {

        foreach my $entry ( @{$result->{'entries'}} ) {

            my $name = $entry->{'name'};
            my $type = $entry->{'.tag'} eq 'folder' ? 'd' : '-';
            my $size = $entry->{'size'};

            $contents{$name} = {
                'type'  => $type,
                'size'  => ( $size ? $size : 1) ,
            };
        }

        last unless $result->{'has_more'};

        $result = $dropbox->list_folder_continue( $result->{'cursor'});
    }

    # The output must look like the results of "ls -l" & contain perms for Historical Reasons
    my @ls = map { "$contents{$_}{'type'}rw-r--r-- X X X $contents{$_}{'size'} X X X $_" } sort keys %contents;

    foreach my $line (@ls) {
        print "$line\n";
    }

    return;
}

#
# Create a directory on the remote destination
#
sub my_mkdir {
    my ( $path, $recurse, $host, $user, $password ) = @_;

    $path = convert_path($path);

    $dropbox->create_folder($path);

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
    my ( $path, $host, $user, $password ) = @_;

    print convert_path($path);
    print "\n";

    return;
}

#
# Recursively delete a directory on the remote destination
#
sub my_rmdir {
    my ( $path, $host, $user, $password ) = @_;

    $path = convert_path($path);

    $dropbox->delete($path);

    return;
}

#
# Delete an individual file on the remote destination
#
sub my_delete {
    my ( $path, $host, $user, $password ) = @_;

    $path = convert_path($path);

    $dropbox->delete($path);

    return;
}
