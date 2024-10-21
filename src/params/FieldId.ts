import type { FieldIdString } from "$lib/appserver/Field";
import type { ParamMatcher } from "@sveltejs/kit";

export function match(param: string): param is FieldIdString {
  return !Number.isNaN(Number.parseInt(param));
}

match satisfies ParamMatcher;
