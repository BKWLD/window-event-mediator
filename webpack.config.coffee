module.exports =

	entry:
		index: './index.coffee'

	module: loaders: [
		{ test: /\.coffee$/, loader: 'coffee-loader' }
	]

	output:
		library: 'window-event-mediator'
		libraryTarget: 'umd'
		filename: if '-p' in process.argv then '[name].min.js' else '[name].js'

	# Every non-relative module is external
	externals: [
		/^[a-z\-0-9]+$/,
	]