use Understand;
use warnings;

my $db = Understand::open("c:\\Users\\lenovo\\Desktop\\test.udb");
my %relative_file_name;	# 文件名
my %begin_line;			# 开始行
my %end_line;			# 结束行
my %bug_num;			# bug数目
my $patch_path = "c:\\Users\\lenovo\\Desktop\\patch\\*";		# 所有补丁的根路径
my @patch_files = glob($patch_path);							# 每个补丁的绝对路径
my $func_count = 0;		# 函数的总个数

foreach $func ($db -> ents("Function ~unresolved ~unknown")) {
	$fileref = $func -> ref("definein");						# 函数引用
	next if (!defined fileref);
	$relative_file_name{$func} = $fileref -> file() -> name();	# 文件名
	$begin_line{$func} = $func -> ref() -> line();				# 函数开始的行号
	$line_count = $func -> metric("CountLineCode");				# 函数行数
	$end_line{$func} = $begin_line{$func} + $line_count;		# 函数结束的行号
	$bug_num{$func} = 0;										# 将每个函数的bug数目初始化为0
	$func_count += 1;											# 统计函数的总个数	
}

foreach my $patch_file (@patch_files){
	open PATCH_FILE, "$patch_file" || die "Can't open file";
	my @all_lines = <PATCH_FILE>;	# 保存每个patch文件的所有内容，供后续处理
	my $matched_fileLine = '';		# 保存最近一次同 ../bash-3.2 匹配的行
	my $matched_bugLine = '';		# 保存同 **** num1,num2 **** 匹配的行
	my $num1;
	my $num2;
	
	for($i = 0; $i < @all_lines; $i++) {
		if(@all_lines[$i] =~ /\.\.\/bash-3.2/) {				# 找出同 ../bash-3.2 匹配的所有行
			$matched_fileLine = @all_lines[$i];
		}
		if(@all_lines[$i] =~ /\*\*\* \d+\,\d+ \*\*\*\*/) {		# 找出同 *** num1,num2 **** 匹配的行
			$matched_bugLine = @all_lines[$i];
			while($matched_bugLine =~ /(\d+).(\d+)/g){			# 提取num1和num2
				$num1 = $1;
				$num2 = $2;
				foreach $func ($db -> ents("Function ~unresolved ~unknown")) {
					if($matched_fileLine =~ $relative_file_name{$func}){	# 遍历函数名哈希表，若找到符合条件的$func键，则将相应的$buf_num{$func}加1
						if($num1 <= $begin_line{$func} && $num2 >= $begin_line{$func} && $num2 <= $end_line{$func} || 
							$num1 <= $begin_line{$func} && $num2 >= $end_line{$func} ||
							$num1 >= $begin_line{$func} && $num1 <= $end_line{$func} && $num2 <= $end_line{$func} ||
							$num1 >= $begin_line{$func} && $num1 <= $end_line{$func} && $num2 >= $end_line{$func}) {
							$bug_num{$func} += 1;
						}
					}
				}
			}
		}
	}
	close PATCH_FILE;
}

open OUTFILE, ">>c:\\Users\\lenovo\\Desktop\\test_result.csv" || die "Can not open file";		# 用追加的方式写入文件
print OUTFILE "FunctionName, RelativePath, CountLineCode, CountPath, Cyclomatic, MaxNesting, Knots, CountInput, CountOutput, Bugs\n";
foreach $func ($db -> ents("function ~unresolved ~unknown")) {
	$name = $func -> longname();	# 函数名
	$val = $func -> ref("definein");
	$relative_path = $val -> file() -> relname() if defined($val);	# 相对路径
	$CodeLine = $func -> metric("CountLineCode");	# CountLineCode
	$CountPath = $func -> metric("CountPath");		# CountPath
	$Cyclomatic = $func -> metric("Cyclomatic");	# Cyclomatic
	$MaxNesting = $func -> metric("MaxNesting");	# MaxNesting
	$Knots = $func -> metric("Knots");				# Knots
	$CountInput = $func -> metric("CountInput");	# CountInput
	$CountOutput = $func -> metric("CountOutput");	# CountOutput
	$Bugs = $bug_num{$func};						# Bugs
	print OUTFILE "$name,$relative_path,$CodeLine,$CountPath,$Cyclomatic,$MaxNesting,$Knots,$CountInput,$CountOutput, $Bugs\n";
}
close OUTFILE;