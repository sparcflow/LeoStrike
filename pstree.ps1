$ProcessesById = @{}
foreach ($Process in (Get-WMIObject -Class Win32_Process)) {
  $ProcessesById[$Process.ProcessId] = $Process
}

$ProcessesWithoutParents = @()
$ProcessesByParent = @{}
foreach ($Pair in $ProcessesById.GetEnumerator()) {
  $Process = $Pair.Value

  if (($Process.ParentProcessId -eq 0) -or !$ProcessesById.ContainsKey($Process.ParentProcessId)) {
    $ProcessesWithoutParents += $Process
    continue
  }

  if (!$ProcessesByParent.ContainsKey($Process.ParentProcessId)) {
    $ProcessesByParent[$Process.ParentProcessId] = @()
  }
  $Siblings = $ProcessesByParent[$Process.ParentProcessId]
  $Siblings += $Process
  $ProcessesByParent[$Process.ParentProcessId] = $Siblings
}

function Show-ProcessTree([UInt32]$ProcessId, $IndentLevel) {
  $Process = $ProcessesById[$ProcessId]
  
  $Indent = ("." * $IndentLevel)
  if ($IndentLevel -eq 0){
	$Indent =""
  }
  $commandline = $Process.CommandLine
  $Name  = $Indent + $Process.Name
  $ExePath = $Process.Executablepath
  $owner = $Process.getowner()
  $user = $owner.domain + "\"  + $owner.user
  $creationdate_str = $Process.ConvertToDateTime($Process.CreationDate)

  Write-Output ("{0,6} {1,-30} {2,-30} {3} {4} {5}" -f $Process.ProcessId, $Name, $user, $creationdate_str, $ExePath, $commandline)
  foreach ($Child in ($ProcessesByParent[$ProcessId] | Sort-Object CreationDate)) {
    Show-ProcessTree $Child.ProcessId ($IndentLevel + 2)
  }
}

Write-Output ("{0,6} {1} {2} {3} {4}" -f "PID", "Name                          ", "User                          ","Creation date      ","Image path")
Write-Output ("{0,6} {1} {2} {3} {4}" -f "---", "----------------------------  ","----------------------------  ","-------------------","-----------")

foreach ($Process in ($ProcessesWithoutParents | Sort-Object CreationDate)) {
  Show-ProcessTree $Process.ProcessId 0
}
