use Understand;
use warnings;

my $db = Understand::open("c:\\Users\\lenovo\\Desktop\\test.udb");
my $working_path = "c:\\Users\\lenovo\\Desktop";    # 工作路径
my %startLine;		# start line
my %endLine;		# end line
my %u1;				# the number of distinct operators
my %u2;				# the number of distinct operands
my %N1;				# the total number of operators
my %N2;				# the total number of operands
my %u;				# Program vocabulary
my %N;				# Program length
my %V;				# Volume
my %u2_star;		# u2_star to calculate V_potential 	
my %V_potential;	# Potential Volume
my %D;				# Difficulty
my %E;				# Effort
my %L;				# Level
my %T;				# Time required to program

# 以2为底的log函数
sub log_base{
	my($base, $value) = @_;
	return log($value) / log($base);
}

# 该函数返回u1,u2,N1,N2, 参考于c_mistra_maint.pl中的代码
sub GetHalsteadBaseMetrics {
    my ($lexer,$startLine,$endLine) = @_;
    my $u1=0;
    my $u2=0;
    my $N1=0;
    my $N2=0;  
    my %n1 = ();
    my %n2 = ();
    
    foreach my $lexeme ($lexer->lexemes($startLine,$endLine)) {
        if(($lexeme->token() eq "Operator") ||
                ($lexeme->token() eq "Keyword") ||
                ($lexeme->token() eq "Punctuation")) {  
            if($lexeme->text() !~ /[)}\]]/) {
                $n1{$lexeme->text()} = 1;
                $N1++;
            } 
        }elsif(($lexeme->token() eq "Identifier") ||
                ($lexeme->token() eq "Literal") || 
				($lexeme->token() eq "String")){
            $n2{$lexeme->text()} = 1;
            $N2++;
        } 
    }
    $u1 = scalar(keys(%n1));
    $u2 = scalar(keys(%n2));  
    return ($u1,$u2,$N1,$N2);
}

chdir($working_path);	# 改变工作路径

foreach $func ($db -> ents("Function ~unresolved ~unknown")) {
	my ($lexer, $status) = $func -> lexer();					# 获取词素
	die $status if($status);
	
	$startLine{$func} = $func -> ref() -> line();				# 函数开始的行号
	$endLine{$func} = $func -> refs("end") -> line();			# 函数结束的行号	
	
	($u1_temp, $u2_temp, $N1_temp, $N2_temp) = GetHalsteadBaseMetrics($lexer, $startLine{$func}, $endLine{$func});
	$u1{$func} = $u1_temp;
	$u2{$func} = $u2_temp;
	$N1{$func} = $N1_temp;
	$N2{$func} = $N2_temp;
	$u{$func} = $u1{$func} + $u2{$func};
	$N{$func} = $N1{$func} + $N2{$func};
	$V{$func} = $N{$func} * log_base(2, $u{$func});
	
	$val = $func -> ref("definein");
	$relative_path = $val -> file() -> relname() if defined($val);	# 得到函数的相对路径
	
	open FUNC_FILE, $relative_path || die "Can't open file";		# 根据当前工作路径和函数相对路径，打开函数所在的文件
	my @all_lines = <FUNC_FILE>;									# 保存文件所有内容
	close FUNC_FILE;
	my $str_funcName = @all_lines[$startLine{$func} - 1];    		# 将函数名所在行的内容存于str_funcName中
	my $arguments_count = ($str_funcName =~ s/\,/\,/g) + 1;			# 用正则匹配s///g计算参数列表中逗号(,)的个数,则参数的个数为逗号的个数加1,即为input variable种类数
	my $funcReturnType = $func -> type();							# 保存函数的返回值类型.若返回值类型为void,则out variable种类为1; 否则out variable种类数为0

	# 计算u2_star
	if($funcReturnType =~ "void"){ 
		$u2_star{$func} = $arguments_count;
	}else{
		$u2_star{$func} = $arguments_count + 1;
	}
	
	$V_potential{$func} = (2 + $u2_star{$func}) * log_base(2, 2 + $u2_star{$func});
	$D{$func} = $V{$func} / $V_potential{$func};
	$E{$func} = $V{$func} * $D{$func};
	$L{$func} = 1 / $D{$func};
	$T{$func} = $E{$func} / 18;    		# 18为经验值
}

open OUTFILE, ">>c:\\Users\\lenovo\\Desktop\\ass4_result.csv" || die "Can not open file";	# 用追加的方式写入文件
print OUTFILE "FunctionName, u1, u2, N1, N2, N, V, D, E, L, T\n";
foreach $func ($db -> ents("function ~unresolved ~unknown")) {
	$name = $func -> longname();
	$u1 = $u1{$func};
	$u2 = $u2{$func};
	$N1 = $N1{$func};
	$N2 = $N2{$func};
	$N = $N{$func};
	$V = $V{$func};
	$D = $D{$func};
	$E = $E{$func};
	$L = $L{$func};
	$T = $T{$func};
	print OUTFILE "$name,$u1,$u2,$N1,$N2,$N,$V,$D,$E,$L,$T\n";
}
close OUTFILE;
