class BuildHash #Class that builds, maintains, and modifies the hash containing the data

	def initHash #Set up empty hash
		@accountsHash = {}
		@wantedHash = {}
	end

	def build(row) #Calls on functions to build hash row by row
		getCurrentInfo(row)
		addAccount
		addCategory
		getAmount
		addCategoryValues
		upBalance
	end

	def getCurrentInfo(row) #Sets variables for working with current row
		@currAccount = row[0].chomp
		@currCategory = row[3].chomp
		@outflow = row[4]
		@inflow = row [5]
	end

	def addAccount #Adds current account to hash if not present already
		if !@accountsHash[@currAccount]
    		@accountsHash[@currAccount] = { :total => 0.0, :category => {}}
    	end
	end

	def addCategory #Adds current category in current account to the hash, if not already present
		if !@accountsHash[@currAccount][:category][@currCategory]
			@accountsHash[@currAccount][:category][@currCategory] = {:tally => 0.0, :num_of_transactions => 0, :avg_transaction => 0.0}
		end
	end

	def addCategoryValues #Updates each categorys values when its the current category in the row
		@accountsHash[@currAccount][:category][@currCategory][:tally] += getAmount
		@accountsHash[@currAccount][:category][@currCategory][:num_of_transactions] += 1
		@accountsHash[@currAccount][:category][@currCategory][:avg_transaction] = averageItOut
	end

	def getAmount #Takes finds the differnet between inflow and outflow
		return inoutFormat(@inflow) - inoutFormat(@outflow)
	end

	def inoutFormat(cost) #Formats numbers given as currency ammounts
		return cost.gsub(/[$]/, '').gsub(/[,]/, '').to_f.round(2)
	end

	def averageItOut #Finds the average money spent per transaction in a category 
		tally = @accountsHash[@currAccount][:category][@currCategory][:tally]
		numOfTransactions = @accountsHash[@currAccount][:category][@currCategory][:num_of_transactions]
		return tally / numOfTransactions.round(2)
	end

	def upBalance #Updates the balance on the entire account
		@accountsHash[@currAccount][:total] += getAmount
	end

	def getKeys #Loads all the account names
		return @accountsHash.keys
	end

	def delete(mfd)	#Deletes accounts that aren't the filter account if a filter is given
		if getKeys.include?(mfd.to_s)
			@accountsHash.delete_if { |key, value| key != mfd.to_s }
		end
		return @accountsHash
	end

	def printOut #Returns the hash for use
		return @accountsHash
	end
end

class Arguments #Takes in agruments, checks arguments, and sets filters
	
	def initArguments #Sets up holders and gets argument variables
		@filter = ARGV
		@name
		@format
		checkARGV
	end

	def checkARGV #Checks to see if too many variables were given
		checkLength
	end

	def checkLength #Aborts if too many arguments were used
		if @filter.length > 2
			abort("error: (invalid agruments)\na max of two arguments are allowed")
		end
	end

	def getValidFilters(keys) #Gets all the names in the hash and sets valid formating filters
		@validNames = keys
		@validFormats = ["ascii", "html", "csv"]
		checkName
		checkFormat
	end

	def checkName #Checks what name is given and if valid is set to name filter, if not valid name is filtered
		if @validNames.include?(@filter[0].to_s)
			@name = @filter[0]
			puts "account to print found: #{@name}"
			@filter.shift
		else
			puts "no option given both accounts to be print"
		end
	end

	def checkFormat #Checks if the given format is valid, defaults to ascii if not
		if @validFormats.include?(@filter[0].to_s)
			@format = @filter[0]
			puts "format to print is: #{@format}"
		else
			puts "no format given defaulting to: #{@validFormats[0]}"
		end
	end

	def filterOutName #Sends name filter for display use
		return @name
	end

	def filterOutFormat #Sends format filter for display use
		return @format
	end
end

class DisplayReport #Class that displays and formats

	def get(filter) #Gets the format filter
		@format = filter.to_s
	end

	def printDisplay(passhash) #Reads filter to determine what display to use
		if @format == "csv"
			csv(passhash)
		elsif @format == "html"
			html(passhash)
		else
			ascii(passhash)
		end
	end

	def ascii(passhash) #Displays ascii is also default
		passhash.each do |name, balance|
			puts "\n"
			puts " _-==========================================================-_"
			puts "|   Account: #{name} 		Balance: \$#{balance[:total].round(2)}             |"
			puts "========================-===============-======================"
			puts "| Category 		| Amount 	| Average Transaction |"
			puts "|-----------------------+---------------+---------------------|"
			balance[:category].each do |category, t|
    			print "| #{category.ljust(21)} | \$#{t[:tally].round(2).to_s.ljust(12)} | \$#{t[:avg_transaction].round(2).to_s.ljust(18)} |\n"
			end
			puts "^=======================^===============^=====================^"
			puts "\n"
		end
	end

	def html(passhash) #Displays in html
		passhash.each do |name, balance|
			puts "\n"
			puts "<h1>#{name}</h1>"
			puts "<p>\$#{balance[:total].round(2)}</p>"
			puts "<hr>"
			puts "<table>"
			puts "	<tr>"
			puts "		<th>Category</th>"
			puts "		<th>Amount</th>"
			puts "		<th>Average Transaction</th>"
			puts "	</tr>"
			balance[:category].each do |category, t|
				puts "	<tr>"
				puts "		<td>#{category}</td>"
				puts "		<td>\$#{t[:tally].round(2).to_s}</td>"
				puts "		<td>\$#{t[:avg_transaction].round(2).to_s}</td>"
				puts "	</tr>"
			end
			puts "</table>"
			puts "\n"
		end
	end

	def csv(passhash) #Displays in csv
		passhash.each do |name, balance|
			puts "\n"
			puts "Category,Amount,Averge Transaction"
			balance[:category].each do |category, t|
				puts "#{category},\$#{t[:tally].round(2).to_s},\$#{t[:avg_transaction].round(2).to_s}"
			end
			puts "\n"
		end
	end
end



def stripNewRow(row)
	cleanRowArray = []
	for i in 0..5
		cleanCell = row[i].gsub(/[,]/, '').gsub(/[$]/, '')
		cleanPush = cleanRowArray.push(cleanCell)
	end
	return cleanPush
end

def addRow(row)
	row = row.join(",")
	File.open("accounts.csv", "a") do |f|
		f.puts row + "\n"
		f.close
	end
end














