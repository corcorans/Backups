# Gets all files and directories recursively and emails then to a specific email address.

package SendBackUpFiles;

use Mail::Sender;
use Cwd;

@back_up_file = ();
@back_up_dir = ();
@files = ();

email_back_ups(get_files(getcwd));

# Gets all files and directories recursively and stores them.
sub get_files {
   my $path = shift;
   
   opendir(DIR, $path) or die "Unable to open $path \n";
   
   @files = 
      # only read files that are not . or ..
      grep { !/^\.{1,2}$/ } 
      readdir (DIR);
      
   closedir(DIR);
   
   # Create the full path starting from C:\
   @files = map { $path . "/" . $_ } @files;
   
   for (@files) {
      if(-d $_ ) {
         push(@back_up_dir, $_, "\n");
         get_files($_);
      } elsif(-f $_) {
         push(@back_up_file, $_, "\n");
      }
   }
   return @back_up_file;
}

# Takes the files that were stored and emails them.
# paramaters are passed from the global array @back_up_files and
# to from the command line argument.
sub email_back_ups {
   my @email_files = @_;
   my $smtp, $form, $to = @ARGV;
   
   print "Files to be sent: \n @email_files";
   
   $sender = new Mail::Sender{ 
      smtp     => $smtp, 
      from     => $from
   };
                  
   $sender -> MailFile({
      to       => $to,
      subject  => 'Back up files requested',
      msg      => 'Here are the back up files as requested.',
      file     => "@email_files",
   });
   
   $sender -> SendEnc or die("Cannot send msg, error msg: $sender"); 
}

exit 1;