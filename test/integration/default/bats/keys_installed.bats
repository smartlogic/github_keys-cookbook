#!/usr/bin/env bats

@test "org member keys are installed" {
  run grep "keys for danivovich" /home/deploy/.ssh/authorized_keys
  [ "$status" -eq 0 ]
}

@test "github user keys are installed" {
  run grep "keys for smarterlogic" /home/deploy/.ssh/authorized_keys
  [ "$status" -eq 0 ]
}

@test "addtional keys are commented" {
  run grep "keys for test_key" /home/deploy/.ssh/authorized_keys
  [ "$status" -eq 0 ]
}

@test "addtional keys are installed" {
  run grep "12345DEADBEEF" /home/deploy/.ssh/authorized_keys
  [ "$status" -eq 0 ]
  run grep "12345CAFEBEEF" /home/deploy/.ssh/authorized_keys
  [ "$status" -eq 0 ]
}
