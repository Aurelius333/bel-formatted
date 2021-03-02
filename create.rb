source = File.read('bel.bel.lisp').split("\n")
readme = File.read('README.md').split("\n")

readme_stuff = []
readme_filtered = readme.select.with_index do |line, i|
	is_magical = line.start_with? '!!'
	if is_magical
		readme_stuff << [i - readme_stuff.length, line.slice(2..(-1))]
	end
	!is_magical
end

source_stuff = {}
source.each.with_index do |line, i|
	if /^\(\S+ (\S+)/.match(line)
		source_stuff[$1] = i
	end
end

chunk_lines = [[0, 0, false]]
readme_stuff.each do |thing|
	readme_line_num, id = thing
	source_line_num = source_stuff[id]
	throw "id not available: #{id}" if !source_line_num
	chunk_lines << [readme_line_num, source_line_num]
end
chunk_lines << [readme.length - 1, source.length - 1]

chunks = chunk_lines.each_cons(2).to_a.map do |pair|
	if pair[1][0] < pair[0][0] || pair[1][1] < pair[0][1]
		raise "not in order"
	end
	[
		readme_filtered.slice(pair[0][0]...pair[1][0]).join("\n"),
		         source.slice(pair[0][1]...pair[1][1]).join("\n")
	]
end

p chunks