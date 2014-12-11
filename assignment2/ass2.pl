use Understand;
use warnings;

my $db = Understand::open("c:\\Users\\lenovo\\Desktop\\test.udb");
my %relative_file_name;	# �ļ���
my %begin_line;			# ��ʼ��
my %end_line;			# ������
my %bug_num;			# bug��Ŀ
my $patch_path = "c:\\Users\\lenovo\\Desktop\\patch\\*";		# ���в����ĸ�·��
my @patch_files = glob($patch_path);							# ÿ�������ľ���·��
my $func_count = 0;		# �������ܸ���

foreach $func ($db -> ents("Function ~unresolved ~unknown")) {
	$fileref = $func -> ref("definein");						# ��������
	next if (!defined fileref);
	$relative_file_name{$func} = $fileref -> file() -> name();	# �ļ���
	$begin_line{$func} = $func -> ref() -> line();				# ������ʼ���к�
	$line_count = $func -> metric("CountLineCode");				# ��������
	$end_line{$func} = $begin_line{$func} + $line_count;		# �����������к�
	$bug_num{$func} = 0;										# ��ÿ��������bug��Ŀ��ʼ��Ϊ0
	$func_count += 1;											# ͳ�ƺ������ܸ���	
}

foreach my $patch_file (@patch_files){
	open PATCH_FILE, "$patch_file" || die "Can't open file";
	my @all_lines = <PATCH_FILE>;	# ����ÿ��patch�ļ����������ݣ�����������
	my $matched_fileLine = '';		# �������һ��ͬ ../bash-3.2 ƥ�����
	my $matched_bugLine = '';		# ����ͬ **** num1,num2 **** ƥ�����
	my $num1;
	my $num2;
	
	for($i = 0; $i < @all_lines; $i++) {
		if(@all_lines[$i] =~ /\.\.\/bash-3.2/) {				# �ҳ�ͬ ../bash-3.2 ƥ���������
			$matched_fileLine = @all_lines[$i];
		}
		if(@all_lines[$i] =~ /\*\*\* \d+\,\d+ \*\*\*\*/) {		# �ҳ�ͬ *** num1,num2 **** ƥ�����
			$matched_bugLine = @all_lines[$i];
			while($matched_bugLine =~ /(\d+).(\d+)/g){			# ��ȡnum1��num2
				$num1 = $1;
				$num2 = $2;
				foreach $func ($db -> ents("Function ~unresolved ~unknown")) {
					if($matched_fileLine =~ $relative_file_name{$func}){	# ������������ϣ�����ҵ�����������$func��������Ӧ��$buf_num{$func}��1
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

open OUTFILE, ">>c:\\Users\\lenovo\\Desktop\\test_result.csv" || die "Can not open file";		# ��׷�ӵķ�ʽд���ļ�
print OUTFILE "FunctionName, RelativePath, CountLineCode, CountPath, Cyclomatic, MaxNesting, Knots, CountInput, CountOutput, Bugs\n";
foreach $func ($db -> ents("function ~unresolved ~unknown")) {
	$name = $func -> longname();	# ������
	$val = $func -> ref("definein");
	$relative_path = $val -> file() -> relname() if defined($val);	# ���·��
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