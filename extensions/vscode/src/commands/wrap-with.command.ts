import { wrapWith } from "../utils";

const scopedBuilderSnippet = (widget: string) => {
  return `ScopedBuilder<$1Store, \${2:Error}, \${3:State}>(
  store: \${4:store},
  onState: (context, state) {
    return ${widget};
  },
)`;
};

const scopedBuilderTransitionSnippet = (widget: string) => {
  return `ScopedBuilder<$1Store, \${2:Error}, \${3:State}>.transition(
  store: \${4:store},
  transition: (_, child) {
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 400),
        child: child,
      );
    },
  onState: (context, state) {
    return ${widget};
  },
)`;
};

const tripleBuilderSnippet = (widget: string) => {
  return `TripleBuilder(
  store: \${1:store},
  builder: (context, triple) {
    return ${widget};
  },
)`;
};

export const wrapWithScopedBuilder = async () => wrapWith(scopedBuilderSnippet);
export const wrapWithScopedBuilderTransition = async () => wrapWith(scopedBuilderTransitionSnippet);
export const wrapWithTripleBuilder = async () => wrapWith(tripleBuilderSnippet);
