const
	gulpElm = require(`gulp-elm`),
	gulpRename = require(`gulp-rename`),
	{ src
	, dest
	, parallel
	, watch
	} = require(`gulp`),
	input = `./`,
	output = `../`,
	globs = {};

globs.elm = input + `src/Main.elm`;
function elm() {
	return src(globs.elm)
		.pipe(gulpElm({cwd: input}))
		.pipe(gulpRename(`elm.js`))
		.pipe(dest(output));
}

async function watchFiles() {
	const cry = {usePolling: true};
	watch(input + `src/**/*.elm`, cry, elm);
}

module.exports = {
	default: parallel(elm, watchFiles),
};
