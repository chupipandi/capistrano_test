100.times do |n|
  User.create(email: "user#{n}@example.com", name: "User#{n}")
end