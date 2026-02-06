export const manifest = (() => {
function __memo(fn) {
	let value;
	return () => value ??= (value = fn());
}

return {
	appDir: "_app",
	appPath: "_app",
	assets: new Set(["favicon.png"]),
	mimeTypes: {".png":"image/png"},
	_: {
		client: {start:"_app/immutable/entry/start.B5rkkVvb.js",app:"_app/immutable/entry/app.v3Vgvfg_.js",imports:["_app/immutable/entry/start.B5rkkVvb.js","_app/immutable/chunks/BXN2zbQS.js","_app/immutable/chunks/Cy0nnqwK.js","_app/immutable/chunks/F8Rf94kU.js","_app/immutable/chunks/CmPt_qt9.js","_app/immutable/entry/app.v3Vgvfg_.js","_app/immutable/chunks/Cy0nnqwK.js","_app/immutable/chunks/Zp7FgOxX.js","_app/immutable/chunks/wnUvJIYz.js","_app/immutable/chunks/DTjTDYf3.js","_app/immutable/chunks/CmPt_qt9.js","_app/immutable/chunks/BxqNGrrm.js","_app/immutable/chunks/C3Bw9t1P.js","_app/immutable/chunks/DIcbJqE8.js","_app/immutable/chunks/IrKOPqpB.js","_app/immutable/chunks/F8Rf94kU.js"],stylesheets:[],fonts:[],uses_env_dynamic_public:false},
		nodes: [
			__memo(() => import('./nodes/0.js')),
			__memo(() => import('./nodes/1.js')),
			__memo(() => import('./nodes/2.js')),
			__memo(() => import('./nodes/3.js')),
			__memo(() => import('./nodes/4.js')),
			__memo(() => import('./nodes/5.js')),
			__memo(() => import('./nodes/6.js')),
			__memo(() => import('./nodes/7.js'))
		],
		remotes: {
			
		},
		routes: [
			{
				id: "/",
				pattern: /^\/$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 3 },
				endpoint: null
			},
			{
				id: "/cards",
				pattern: /^\/cards\/?$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 6 },
				endpoint: null
			},
			{
				id: "/(socket)/field/[fieldId=FieldId]",
				pattern: /^\/field\/([^/]+?)\/?$/,
				params: [{"name":"fieldId","matcher":"FieldId","optional":false,"rest":false,"chained":false}],
				page: { layouts: [0,2,], errors: [1,,], leaf: 4 },
				endpoint: null
			},
			{
				id: "/(socket)/overworld",
				pattern: /^\/overworld\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 5 },
				endpoint: null
			},
			{
				id: "/play",
				pattern: /^\/play\/?$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 7 },
				endpoint: null
			}
		],
		prerendered_routes: new Set([]),
		matchers: async () => {
			const { match: FieldId } = await import ('./entries/matchers/FieldId.js')
			return { FieldId };
		},
		server_assets: {}
	}
}
})();
