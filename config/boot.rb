# Set up gems listed in the Gemfile.
require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

ENV['VERSION'] = "&copy2010, 2014 idlika partners LLC v0.75 "

# below was in locals/environment.#!/usr/bin/env ruby
# AMAZON
ENV['IDLIKA_VERSION'] = '0.73 page security'
ENV['DEFAULT_REGISTRY_NAME'] = 'home index'
ENV['SHOW_LINKS'] = 'yes'

ENV['S3_BUCKET'] = "idlika.com"
ENV['S3_KEY'] = 'AKIAJG2MA6FIXEPKVC6Q'
ENV['S3_SECRET'] = '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'

ENV['IDLIKA_EMAIL_NAME'] = 'info@idlikallc.com'
ENV['IDLIKA_EMAIL_PSWD'] = 'idl1kallc'
ENV['IDLIKA_DOMAIN'] = 'idlika.com'

ENV['SENDGRID_PASSWORD'] = '6c849eca761a22707a'
ENV['SENDGRID_USERNAME'] = 'app156298@heroku.com'

ENV['INVITATION_USERNAME'] = 'guest'
ENV['INVITATION_PASSWORD'] = 'guest'

# Facebook Registration 
# App Name:	idlika
# App URL:	www.idlika.com/home/
# App ID:	143400042352343
# App Secret:	1482ae818ff5f6adae68679612f17a79
ENV['FACEBOOK_APP_ID'] = '143400042352343'

RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)
