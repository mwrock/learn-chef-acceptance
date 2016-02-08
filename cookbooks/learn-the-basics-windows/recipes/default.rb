#
# Cookbook Name:: learn-the-basics-windows
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
Chef::Recipe.send(:include, LearnChef::Workflow)

include_recipe 'learn-the-basics-windows::setup'
include_recipe 'learn-the-basics-windows::lesson1'
#include_recipe 'learn-the-basics-windows::_lesson2'
#include_recipe 'learn-the-basics-windows::_lesson3'
