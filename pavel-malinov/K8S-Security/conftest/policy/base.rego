package main

denyimageslist = [
  "ubuntu",
  "alpine"
]

deny[msg_images] {
  input[i].Cmd == "from"
  val := input[i].Value
  contains(val[i], denyimageslist[_])

  msg_images = sprintf("unallowed image found %s", [val])
}

denycommandslist = [
  "wget",
  "curl",
]

deny[msg_commands] {
  input[i].Cmd == "run"
  val := input[i].Value
  contains(val[_], denycommandslist[_])

  msg_commands = sprintf("unallowed commands found %s", [val])
}
