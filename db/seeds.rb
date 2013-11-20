# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# Works best with rake db:reset
#
roles_list = %w[ admin demo staff support operations sales ]

roles_list.each do |role|
  Role.create!(name: role)
end

# Create users (roles not implemented yet, MUST be chosen from roles_list)

user_list = [
  [ "admin", "admin@example.com" ],
  [ "staff", "staff@example.com" ], 
  [ "john", "john@venuesoftware.com" ],
  [ "peta", "peta.forbes@roster365.com.au" ],
  [ "tony", "tgodino@me.com" ]
  ]
user_list.each do |username, email, role|  
  User.create!( 
  	          friends: "",
  	          username: username,
  	          email: email, 
  	          password: '12345', 
              password_confirmation: '12345'
  	          )
end

