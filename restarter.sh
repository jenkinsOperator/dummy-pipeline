#!/bin/#!/usr/bin/env bash

for num; do
  kubectl -n jenkins delete -f $num
done

for num; do
  kubectl -n jenkins create -f $num
done

