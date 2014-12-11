use Understand;
use warnings;

$db = Understand::open("c:\\Users\\lenovo\\Desktop\\test.udb");
open(OUTFILE, ">>./test_result.csv") || die("Can not open file");	# ��׷�ӵķ�ʽд���ļ�

print OUTFILE "FunctionName, RelativePath, CountLineCode, CountPath, Cyclomatic, MaxNesting, Knots, CountInput, CountOutput, \n";
foreach $func ($db -> ents("function ~unresolved ~unknown")) {
	$name = $func -> longname();	# ������
	$val = $func -> ref("definein");
	$relative_path = $val -> file() -> relname() if defined($val);	# ���·��
	$CodeLine = $func -> metric("CountLineCode");	# CountLineCode
	$CountPath = $func -> metric("CountPath");	# CountPath
	$Cyclomatic = $func -> metric("Cyclomatic");	# Cyclomatic
	$MaxNesting = $func -> metric("MaxNesting");	# MaxNesting
	$Knots = $func -> metric("Knots");	# Knots
	$CountInput = $func -> metric("CountInput");	# CountInput
	$CountOutput = $func -> metric("CountOutput");	# CountOutput
	print OUTFILE "$name,$relative_path,$CodeLine,$CountPath,$Cyclomatic,$MaxNesting,$Knots,$CountInput,$CountOutput,\n";
}

close(OUTFILE);
