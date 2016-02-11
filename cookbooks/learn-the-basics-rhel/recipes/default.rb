#
# Cookbook Name:: learn-the-basics-rhel
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'sudo::default'
include_recipe 'learn-the-basics-rhel::setup'
include_recipe 'learn-the-basics-rhel::lesson1'
include_recipe 'learn-the-basics-rhel::lesson2'
include_recipe 'learn-the-basics-rhel::lesson3'
