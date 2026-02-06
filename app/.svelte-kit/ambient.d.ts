
// this file is generated — do not edit it


/// <reference types="@sveltejs/kit" />

/**
 * Environment variables [loaded by Vite](https://vitejs.dev/guide/env-and-mode.html#env-files) from `.env` files and `process.env`. Like [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private), this module cannot be imported into client-side code. This module only includes variables that _do not_ begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) _and do_ start with [`config.kit.env.privatePrefix`](https://svelte.dev/docs/kit/configuration#env) (if configured).
 * 
 * _Unlike_ [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private), the values exported from this module are statically injected into your bundle at build time, enabling optimisations like dead code elimination.
 * 
 * ```ts
 * import { API_KEY } from '$env/static/private';
 * ```
 * 
 * Note that all environment variables referenced in your code should be declared (for example in an `.env` file), even if they don't have a value until the app is deployed:
 * 
 * ```
 * MY_FEATURE_FLAG=""
 * ```
 * 
 * You can override `.env` values from the command line like so:
 * 
 * ```sh
 * MY_FEATURE_FLAG="enabled" npm run dev
 * ```
 */
declare module '$env/static/private' {
	export const DATABASE_URL: string;
	export const SHADOW_DATABASE_URL: string;
	export const ROOT_DATABASE_URL: string;
	export const npm_package_engines_npm: string;
	export const fish_color_param: string;
	export const LDFLAGS: string;
	export const MANPATH: string;
	export const __MISE_DIFF: string;
	export const TERM_PROGRAM: string;
	export const NODE: string;
	export const fish_color_normal: string;
	export const INIT_CWD: string;
	export const GEM_HOME: string;
	export const SHELL: string;
	export const TERM: string;
	export const CPPFLAGS: string;
	export const HOMEBREW_REPOSITORY: string;
	export const PIPENV_VENV_IN_PROJECT: string;
	export const TMPDIR: string;
	export const npm_config_global_prefix: string;
	export const GOBIN: string;
	export const LLVM_SYS_191_PREFIX: string;
	export const TERM_PROGRAM_VERSION: string;
	export const CONCURRENTLY_PAD_PREFIX: string;
	export const JUST_CHOOSER: string;
	export const fish_color_escape: string;
	export const COLOR: string;
	export const npm_config_noproxy: string;
	export const npm_config_local_prefix: string;
	export const USER: string;
	export const fish_color_operator: string;
	export const LD_LIBRARY_PATH: string;
	export const COMMAND_MODE: string;
	export const skin: string;
	export const npm_config_globalconfig: string;
	export const fish_color_autosuggestion: string;
	export const SSH_AUTH_SOCK: string;
	export const __CF_USER_TEXT_ENCODING: string;
	export const fish_color_search_match: string;
	export const npm_execpath: string;
	export const SKIM_DEFAULT_COMMAND: string;
	export const TMUX: string;
	export const LLVM_SYS_211_PREFIX: string;
	export const WEZTERM_EXECUTABLE_DIR: string;
	export const fish_color_match: string;
	export const PATH: string;
	export const fish_color_selection: string;
	export const fish_color_tab: string;
	export const npm_package_json: string;
	export const _: string;
	export const npm_config_userconfig: string;
	export const npm_config_init_module: string;
	export const __CFBundleIdentifier: string;
	export const fish_color_user: string;
	export const npm_command: string;
	export const CONCURRENTLY_KILL_OTHERS: string;
	export const PWD: string;
	export const npm_lifecycle_event: string;
	export const EDITOR: string;
	export const npm_package_name: string;
	export const LANG: string;
	export const WEZTERM_PANE: string;
	export const fish_color_history_current: string;
	export const CLOUDSDK_PYTHON: string;
	export const npm_config_npm_version: string;
	export const TMUX_PANE: string;
	export const XPC_FLAGS: string;
	export const fish_color_cancel: string;
	export const fish_color_quote: string;
	export const CONCURRENTLY_PREFIX_COLORS: string;
	export const FORCE_COLOR: string;
	export const npm_package_engines_node: string;
	export const fish_color_error: string;
	export const npm_config_node_gyp: string;
	export const RBENV_SHELL: string;
	export const npm_package_version: string;
	export const WEZTERM_UNIX_SOCKET: string;
	export const XPC_SERVICE_NAME: string;
	export const GPG_TTY: string;
	export const fish_color_comment: string;
	export const fish_color_cwd_root: string;
	export const HOME: string;
	export const SHLVL: string;
	export const GOROOT: string;
	export const __MISE_ORIG_PATH: string;
	export const HOMEBREW_PREFIX: string;
	export const fish_color_command: string;
	export const fish_color_end: string;
	export const scripts: string;
	export const MISE_SHELL: string;
	export const WEZTERM_CONFIG_DIR: string;
	export const fish_color_cwd: string;
	export const npm_config_cache: string;
	export const LOGNAME: string;
	export const npm_lifecycle_script: string;
	export const FZF_DEFAULT_COMMAND: string;
	export const BUN_INSTALL: string;
	export const fish_color_status: string;
	export const fish_color_vcs: string;
	export const npm_config_user_agent: string;
	export const HOMEBREW_CELLAR: string;
	export const INFOPATH: string;
	export const __MISE_SESSION: string;
	export const WEZTERM_EXECUTABLE: string;
	export const fish_color_redirection: string;
	export const fish_color_valid_path: string;
	export const WEZTERM_CONFIG_FILE: string;
	export const npm_node_execpath: string;
	export const npm_config_prefix: string;
	export const COLORTERM: string;
	export const fish_color_host: string;
	export const NODE_ENV: string;
}

/**
 * Similar to [`$env/static/private`](https://svelte.dev/docs/kit/$env-static-private), except that it only includes environment variables that begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) (which defaults to `PUBLIC_`), and can therefore safely be exposed to client-side code.
 * 
 * Values are replaced statically at build time.
 * 
 * ```ts
 * import { PUBLIC_BASE_URL } from '$env/static/public';
 * ```
 */
declare module '$env/static/public' {
	export const PUBLIC_SERVER_URL: string;
	export const PUBLIC_SERVER_WS_URL: string;
}

/**
 * This module provides access to runtime environment variables, as defined by the platform you're running on. For example if you're using [`adapter-node`](https://github.com/sveltejs/kit/tree/main/packages/adapter-node) (or running [`vite preview`](https://svelte.dev/docs/kit/cli)), this is equivalent to `process.env`. This module only includes variables that _do not_ begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) _and do_ start with [`config.kit.env.privatePrefix`](https://svelte.dev/docs/kit/configuration#env) (if configured).
 * 
 * This module cannot be imported into client-side code.
 * 
 * ```ts
 * import { env } from '$env/dynamic/private';
 * console.log(env.DEPLOYMENT_SPECIFIC_VARIABLE);
 * ```
 * 
 * > [!NOTE] In `dev`, `$env/dynamic` always includes environment variables from `.env`. In `prod`, this behavior will depend on your adapter.
 */
declare module '$env/dynamic/private' {
	export const env: {
		DATABASE_URL: string;
		SHADOW_DATABASE_URL: string;
		ROOT_DATABASE_URL: string;
		npm_package_engines_npm: string;
		fish_color_param: string;
		LDFLAGS: string;
		MANPATH: string;
		__MISE_DIFF: string;
		TERM_PROGRAM: string;
		NODE: string;
		fish_color_normal: string;
		INIT_CWD: string;
		GEM_HOME: string;
		SHELL: string;
		TERM: string;
		CPPFLAGS: string;
		HOMEBREW_REPOSITORY: string;
		PIPENV_VENV_IN_PROJECT: string;
		TMPDIR: string;
		npm_config_global_prefix: string;
		GOBIN: string;
		LLVM_SYS_191_PREFIX: string;
		TERM_PROGRAM_VERSION: string;
		CONCURRENTLY_PAD_PREFIX: string;
		JUST_CHOOSER: string;
		fish_color_escape: string;
		COLOR: string;
		npm_config_noproxy: string;
		npm_config_local_prefix: string;
		USER: string;
		fish_color_operator: string;
		LD_LIBRARY_PATH: string;
		COMMAND_MODE: string;
		skin: string;
		npm_config_globalconfig: string;
		fish_color_autosuggestion: string;
		SSH_AUTH_SOCK: string;
		__CF_USER_TEXT_ENCODING: string;
		fish_color_search_match: string;
		npm_execpath: string;
		SKIM_DEFAULT_COMMAND: string;
		TMUX: string;
		LLVM_SYS_211_PREFIX: string;
		WEZTERM_EXECUTABLE_DIR: string;
		fish_color_match: string;
		PATH: string;
		fish_color_selection: string;
		fish_color_tab: string;
		npm_package_json: string;
		_: string;
		npm_config_userconfig: string;
		npm_config_init_module: string;
		__CFBundleIdentifier: string;
		fish_color_user: string;
		npm_command: string;
		CONCURRENTLY_KILL_OTHERS: string;
		PWD: string;
		npm_lifecycle_event: string;
		EDITOR: string;
		npm_package_name: string;
		LANG: string;
		WEZTERM_PANE: string;
		fish_color_history_current: string;
		CLOUDSDK_PYTHON: string;
		npm_config_npm_version: string;
		TMUX_PANE: string;
		XPC_FLAGS: string;
		fish_color_cancel: string;
		fish_color_quote: string;
		CONCURRENTLY_PREFIX_COLORS: string;
		FORCE_COLOR: string;
		npm_package_engines_node: string;
		fish_color_error: string;
		npm_config_node_gyp: string;
		RBENV_SHELL: string;
		npm_package_version: string;
		WEZTERM_UNIX_SOCKET: string;
		XPC_SERVICE_NAME: string;
		GPG_TTY: string;
		fish_color_comment: string;
		fish_color_cwd_root: string;
		HOME: string;
		SHLVL: string;
		GOROOT: string;
		__MISE_ORIG_PATH: string;
		HOMEBREW_PREFIX: string;
		fish_color_command: string;
		fish_color_end: string;
		scripts: string;
		MISE_SHELL: string;
		WEZTERM_CONFIG_DIR: string;
		fish_color_cwd: string;
		npm_config_cache: string;
		LOGNAME: string;
		npm_lifecycle_script: string;
		FZF_DEFAULT_COMMAND: string;
		BUN_INSTALL: string;
		fish_color_status: string;
		fish_color_vcs: string;
		npm_config_user_agent: string;
		HOMEBREW_CELLAR: string;
		INFOPATH: string;
		__MISE_SESSION: string;
		WEZTERM_EXECUTABLE: string;
		fish_color_redirection: string;
		fish_color_valid_path: string;
		WEZTERM_CONFIG_FILE: string;
		npm_node_execpath: string;
		npm_config_prefix: string;
		COLORTERM: string;
		fish_color_host: string;
		NODE_ENV: string;
		[key: `PUBLIC_${string}`]: undefined;
		[key: `${string}`]: string | undefined;
	}
}

/**
 * Similar to [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private), but only includes variables that begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) (which defaults to `PUBLIC_`), and can therefore safely be exposed to client-side code.
 * 
 * Note that public dynamic environment variables must all be sent from the server to the client, causing larger network requests — when possible, use `$env/static/public` instead.
 * 
 * ```ts
 * import { env } from '$env/dynamic/public';
 * console.log(env.PUBLIC_DEPLOYMENT_SPECIFIC_VARIABLE);
 * ```
 */
declare module '$env/dynamic/public' {
	export const env: {
		PUBLIC_SERVER_URL: string;
		PUBLIC_SERVER_WS_URL: string;
		[key: `PUBLIC_${string}`]: string | undefined;
	}
}
