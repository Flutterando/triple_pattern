
import { commands, ExtensionContext, languages } from 'vscode';
import { FlutterTripleCodeActionProvider } from './code-actions';
import { wrapWithScopedBuilder, wrapWithScopedBuilderTransition, wrapWithTripleBuilder } from "./commands";

const DART_MODE = { language: "dart", scheme: "file" };

export function activate(context: ExtensionContext) {

	context.subscriptions.push(
		commands.registerCommand("extension.wrap-scopedbuilder", wrapWithScopedBuilder),
		commands.registerCommand("extension.wrap-scopedbuildertransition", wrapWithScopedBuilderTransition),
		commands.registerCommand("extension.wrap-triplebuilder", wrapWithTripleBuilder),
		languages.registerCodeActionsProvider(
			DART_MODE,
			new FlutterTripleCodeActionProvider()
		),
	);
}

export function deactivate() { }
