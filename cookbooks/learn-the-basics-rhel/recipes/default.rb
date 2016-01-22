#
# Cookbook Name:: learn-the-basics-rhel
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
Chef::Recipe.send(:include, LearnChef::Workflow)

include_recipe 'learn-the-basics-rhel::_setup'
include_recipe 'learn-the-basics-rhel::_lesson1'
include_recipe 'learn-the-basics-rhel::_lesson2'
include_recipe 'learn-the-basics-rhel::_lesson3'
