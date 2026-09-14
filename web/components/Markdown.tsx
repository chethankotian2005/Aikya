"use client";

import ReactMarkdown from "react-markdown";

/** Renders Gemini-generated Markdown with the AIKYA type scale. */
export default function Markdown({ children }: { children: string }) {
  return (
    <div className="space-y-3 text-sm leading-relaxed text-text-secondary">
      <ReactMarkdown
        components={{
          h1: (p) => <h2 className="mt-4 text-xl font-bold text-text-primary" {...p} />,
          h2: (p) => <h3 className="mt-4 text-lg font-bold text-text-primary" {...p} />,
          h3: (p) => <h4 className="mt-3 font-semibold text-text-primary" {...p} />,
          ul: (p) => <ul className="list-disc space-y-1 pl-5" {...p} />,
          ol: (p) => <ol className="list-decimal space-y-1 pl-5" {...p} />,
          strong: (p) => <strong className="font-semibold text-text-primary" {...p} />,
          table: (p) => (
            <div className="overflow-x-auto">
              <table className="w-full border-collapse text-left text-xs" {...p} />
            </div>
          ),
          th: (p) => <th className="border border-border bg-primary-container px-2 py-1" {...p} />,
          td: (p) => <td className="border border-border px-2 py-1" {...p} />,
        }}
      >
        {children}
      </ReactMarkdown>
    </div>
  );
}
