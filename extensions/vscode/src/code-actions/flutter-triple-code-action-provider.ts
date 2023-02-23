import { window, CodeAction, CodeActionProvider, CodeActionKind } from "vscode";
import { getSelectedText } from "../utils";

export class FlutterTripleCodeActionProvider implements CodeActionProvider {
  public provideCodeActions(): CodeAction[] {
    const editor = window.activeTextEditor;
    if (!editor) return [];

    const selectedText = editor.document.getText(getSelectedText(editor));
    if (selectedText === "") return [];

    return [
      {
        command: "extension.wrap-scopedbuilder",
        title: "Wrap with ScopedBuilder",
      },
      {
        command: "extension.wrap-scopedbuildertransition",
        title: "Wrap with ScopedBuilder.transition",
      },
      {
        command: "extension.wrap-triplebuilder",
        title: "Wrap with TripleBuilder",
      }
    ].map((c) => {
      let action = new CodeAction(c.title, CodeActionKind.Refactor);
      action.command = {
        command: c.command,
        title: c.title,
      };
      return action;
    });
  }
}
