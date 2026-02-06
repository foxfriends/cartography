
// this file is generated — do not edit it


declare module "svelte/elements" {
	export interface HTMLAttributes<T> {
		'data-sveltekit-keepfocus'?: true | '' | 'off' | undefined | null;
		'data-sveltekit-noscroll'?: true | '' | 'off' | undefined | null;
		'data-sveltekit-preload-code'?:
			| true
			| ''
			| 'eager'
			| 'viewport'
			| 'hover'
			| 'tap'
			| 'off'
			| undefined
			| null;
		'data-sveltekit-preload-data'?: true | '' | 'hover' | 'tap' | 'off' | undefined | null;
		'data-sveltekit-reload'?: true | '' | 'off' | undefined | null;
		'data-sveltekit-replacestate'?: true | '' | 'off' | undefined | null;
	}
}

export {};


declare module "$app/types" {
	export interface AppTypes {
		RouteId(): "/(socket)" | "/" | "/cards" | "/(socket)/field" | "/(socket)/field/[fieldId=FieldId]" | "/(socket)/field/[fieldId=FieldId]/components" | "/(socket)/overworld" | "/(socket)/overworld/components" | "/play";
		RouteParams(): {
			"/(socket)/field/[fieldId=FieldId]": { fieldId: string };
			"/(socket)/field/[fieldId=FieldId]/components": { fieldId: string }
		};
		LayoutParams(): {
			"/(socket)": { fieldId?: string };
			"/": { fieldId?: string };
			"/cards": Record<string, never>;
			"/(socket)/field": { fieldId?: string };
			"/(socket)/field/[fieldId=FieldId]": { fieldId: string };
			"/(socket)/field/[fieldId=FieldId]/components": { fieldId: string };
			"/(socket)/overworld": Record<string, never>;
			"/(socket)/overworld/components": Record<string, never>;
			"/play": Record<string, never>
		};
		Pathname(): "/" | "/cards" | "/cards/" | "/field" | "/field/" | `/field/${string}` & {} | `/field/${string}/` & {} | `/field/${string}/components` & {} | `/field/${string}/components/` & {} | "/overworld" | "/overworld/" | "/overworld/components" | "/overworld/components/" | "/play" | "/play/";
		ResolvedPathname(): `${"" | `/${string}`}${ReturnType<AppTypes['Pathname']>}`;
		Asset(): "/favicon.png" | string & {};
	}
}