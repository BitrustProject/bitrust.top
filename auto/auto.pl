#!/usr/bin/perl
use File::Path;
use File::Copy;
use File::Find;
use constant {
    ACP_NAME => 1,
    ACP_JIRA=> 2,
    ACP_SVCS => 3,
    ACP_BACKUP => 4,
    ACP_DEPLOY => 5,
    ACP_CKSUM => 6
};

use constant {
        KEY_FILE=>"\[FILE\]",
        KEY_MENU=>"\[MENU\]",
        KEY_LEFTMENU=>"\[LEFTMENU\]",
        KEY_CONTENT=>"\[LEFTMENU\]"		
};
#maybe support linux in the future 

# this part is version history
#$version="1.0 --- Dec, 2014" 
#
$version="1.0 --- Dec, 2014";

$OK=0;
$ERROR=-1;
#pattern (uname -p) to distinguish system arch 

my $cp_conf_file;
if(defined($ARGV[0]))
{
   $cp_conf_file = $ARGV[0]; 
}
else
{
  die "no config file specified";
}

open(CONF, $cp_conf_file) or die "failed to open config file:$cp_conf_file";
#print("[CONF]$cp_conf_file configuration loaded\n");
my $title="";
my $filename="";
my $filetemp="";


my $menustr;
my $leftmenustr;
my $content;
		  my @menuname;
		  my @menudata;
		  my @menulink;
		  my @menutemp;
print $cp_conf_file;
while ($line=<CONF>)
{		
		print "  --cont is $line";
		chomp($line);
		if($line =~/\[FILE\]/)
		{
		  print "find .KEY_FILE\n";

		  while($inline=<CONF>)
		  {
		  print "  ---inline is $inline";
			if($inline =~/^\[/)
			{
				last;
			}
			elsif($inline =~/TITLE=(.*)/)
			{
				$title = $1;
				print "title is $1\n";
				
			}
			elsif($inline=~/NAME=(.*)/)
			{
				$filename=$1;
				print "name is $1\n";
			}
			elsif($inline=~/FILETEMPLATE=(.*)/)
			{
				$filetemp = $1;
				print "file template is $1\n";
			}			
		  }
		  
		}
		elsif($line =~/\[MENU\]/)
		{
		  print "find .KEY_MENU -- $line\n";	
		  my $mtemp;
		  my $mtempcopy;
		  my $cur="";
		  while($inline=<CONF>)
		  {
			print $inline;
			if($inline =~/^\[/)
			{
				last;
			}
			elsif($inline =~/MENUTEMPLATE=(.*)/)
			{			
				$mtemp = $1;
				print "menu template is $1\n";
				
			}
			elsif($inline=~/^MENUCUR=(.*)/)
			{
				$cur = $1;
				#$mtempcopy=$mtemp;
				#$mtempcopy=~s/#CUR/$cur/;
				
			}
			elsif($inline=~/^MENUNAME=(.*)/)
			{
				print "menu name is $1\n";
				print "menu cur is $cur\n";
				$name = $1;
				$mtempcopy=$mtemp;

				$mtempcopy=~s/#CUR/$cur/;
				$mtempcopy=~s/#MENUNAME/$name/;
				$cur="";
			}
			elsif($inline=~/^MENULINK=(.*)/)
			{
				print "menu link is $1\n";
				$link = $1;
				$mtempcopy=~s/#MENULINK/$link/;
				$menustr.=$mtempcopy;
			}			
		  }	
		  print $menustr;
		}

		elsif($line =~/\[LEFTMENU\]/)
		{
		  print "find .KEY_LEFTMENU\n";
		  my $cur;
		  my $mtemp;
		  my $mtempcopy;
		  my $menustart, $menuend, $cattemp, $catname, $linkbase;

		  while($inline=<CONF>)
		  {
			if($inline =~/^\[/)
			{
				last;
			}

			elsif($inline =~/MENUSTART=(.*)/)
			{
				$menustart = $1;
				$leftmenustr.=$menustart;
				print "menu start is: $1\n";
				
			}
			elsif($inline=~/MENUEND=(.*)/)
			{
				$menuend=$1;
				print "menu end is:$1\n";
			}
			elsif($inline=~/CATTEMPLATE=(.*)/)
			{
				$cattemp = $1;
				print "cat temp is $1\n";
			}
			elsif($inline=~/CATNAME=(.*)/)
			{
				$catname = $1;
				$cattemp=~s/#CATNAME/$catname/;
				print "cat name is $catname\n";
				$leftmenustr.=$cattemp;
			}			
			elsif($inline =~/MENUTEMPLATE=(.*)/)
			{
				$mtemp=$1;
				
				print "menu template is :$1";
				
			}
			elsif($inline =~/MENULINKBASE=(.*)/)
			{
				$linkbase=$1;
				
				print "menu linkbase is :$1";
				
			}
			elsif($inline=~/^MENUCUR=(.*)/)
			{
				$cur = $1;
				#$mtempcopy=$mtemp;
				#$mtempcopy=~s/#CUR/$cur/;
				
			}
			elsif($inline=~/MENUNAME=(.*)/)
			{
				
				$name = $1;
				push(@menuname, $name);
				$mtempcopy=$mtemp;
				$mtempcopy=~s/#CUR/$cur/;
				$mtempcopy=~s/#MENUNAME/$name/;
				$cur="";
			}
			elsif($inline=~/MENULINK=(.*)/)
			{
				$link = $1;
				push(@menulink, $link);
				$mtempcopy=~s/#MENULINK/$link/;
				$leftmenustr.=$mtempcopy;
			}
			elsif($inline=~/DATAIN=(.*)/)
			{
				push(@menudata, $1);				
			}
		  }
		  my $menucnt = @menuname;
		  for($i=0;$i<$menucnt;$i++)
		  {
			
			$menutemp="";
			$menutemp.=$menustart;
			$menutemp.=$cattemp;
			for($j=0;$j<$menucnt;$j++)
			{
				$mtempcopy=$mtemp;
				my $curstr="";
				if($i==$j)
				{
					$curstr="cur";
				}
				$mtempcopy=~s/#CUR/$curstr/;
				$mtempcopy=~s/#MENUNAME/@menuname[$j]/;
				$mtempcopy=~s/#MENULINK/$linkbase@menulink[$j]/;
				
				$menutemp.=$mtempcopy;
			}
			$menutemp.=$menuend;
			print $menutemp;
			@menutemp[$i]=$menutemp;
		  }
		}

		elsif($line =~/\[CONTENT\]/)
		{
		  print "find KEY_CONTENT\n";	
		  while($inline=<CONF>)
		  {
			if($inline =~/^\[/)
			{
				last;
			}
            $content.=$inline;			
		  }			
		}
	}
close(CONF);

$idx=0;
my $menucnt = @menulink;
print $menucnt;
for($idx=0;$idx<$menucnt;$idx++)
{
my $menufile = @menulink[$idx];
open(FILEIN, $filetemp) or die "failed to open in file:$filetemp";
open(FILEOUT,">$menufile") or die "failed to open out file: $menufile";
while($line=<FILEIN>)
{
	
	if($line=~s/#TITLE/$menuname[$idx]/)
	{
	}
	elsif($line=~s/#MENU/$menustr/)
	{
	}
	elsif($line=~s/#LEFTMENU/@menutemp[$idx]/)
	{
	}
	elsif($line=~/#CONTENT/)
	{
		if(@menudata[$idx])
		{
			open(DATA, @menudata[$idx]);
			if(DATA)
			{
				@cont=<DATA>;
				$content="@cont";
				$line=~s/#CONTENT/$content/
			}
		}
	}
	print FILEOUT $line;
}

close(FILEIN);
close(FILEOUT);
}
