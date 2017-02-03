require_relative 'CSVclasses.rb'
require 'CSV'
require 'sinatra'
require 'pry'

def buildItAndTheyWillCome
	accountsHash = BuildHash.new
	accountsHash.initHash

	CSV.foreach("accounts.csv", {headers: true, return_headers: false}) do |row|
		accountsHash.build(row)
	end
	return accountsHash
end

#THIS IS A CONTROLLER
get("/"){
	erb :home
}



#THIS IS A CONTROLLER
post("/fullreport"){
	
	redirect("/fullreport")
}


#THIS IS A CONTROLLER
get("/fullreport"){
	@name = params["whoWeWant"]

	@passHash = buildItAndTheyWillCome.delete(@name)

	
	erb :banana
}

get("/login"){
	erb :login
}

post("/login"){
	@name = params["userID"]
	@password = params["password"]
	$loggedIn = false

	if @name == "bossman"
		$loggedIn = true

		redirect "/admin"
	end

	erb :login
}

get("/logout"){
	erb :logout
}
post("/logout"){
	$loggedIn = false
	erb :logout
}

get("/admin"){
	@passHash = buildItAndTheyWillCome.delete(@name)
	erb :admin
}

post("/admin"){
	@newStuff = params.values
	@cleanNewStuff = stripNewRow(@newStuff)
	addRow(@cleanNewStuff)
	
	redirect("/admin")
	erb :admin
}

# post("/fullreport"){
# 	@name = params["whoWeWant"]
# 	@passHash = buildItAndTheyWillCome.printOut.delete(@name)
# 	erb :banana
# }

# get("/Sonia"){
# 	@passHash = buildItAndTheyWillCome.delete("Sonia")
	
# 	erb :banana
# }

get("/Priya"){
	buildItAndTheyWillCome
	@passHash = buildItAndTheyWillCome.delete("Priya")
	erb :banana
}