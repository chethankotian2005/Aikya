"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { addDoc, collection, serverTimestamp } from "firebase/firestore";
import { ImagePlus } from "lucide-react";
import { db } from "@/lib/firebase/firebase";
import { useAuth } from "@/lib/auth-context";
import { friendlyError } from "@/lib/errors";
import { uniqueFileName, uploadImage } from "@/lib/upload";
import { ErrorText, PageHeader, PageSpinner } from "@/components/ui";

export default function ProjectForm() {
  const { profile } = useAuth();
  const router = useRouter();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [techStack, setTechStack] = useState("");
  const [repoUrl, setRepoUrl] = useState("");
  const [teammate, setTeammate] = useState(false);
  const [image, setImage] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  if (!profile) return <PageSpinner />;

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    const tech = [...new Set(techStack.split(",").map((t) => t.trim()).filter(Boolean))].slice(0, 10);
    if (title.trim().length < 3) return setError("Title must be at least 3 characters.");
    if (!description.trim()) return setError("Description is required.");
    if (tech.length === 0) return setError("Add at least one technology.");
    if (repoUrl.trim() && !/^https?:\/\//.test(repoUrl.trim())) return setError("Link must start with https://");

    setSaving(true);
    try {
      const imageUrl = image ? await uploadImage(image, `projects/${profile.uid}/${uniqueFileName(image)}`) : null;
      const ref = await addDoc(collection(db, "projects"), {
        title: title.trim(),
        description: description.trim(),
        techStack: tech,
        images: imageUrl ? [imageUrl] : [],
        ownerUid: profile.uid,
        ownerName: profile.fullName,
        contributors: [],
        lookingForTeammate: teammate,
        repoUrl: repoUrl.trim() || null,
        createdAt: serverTimestamp(),
      });
      router.replace(`/projects/${ref.id}`);
    } catch (err) {
      setError(friendlyError(err));
      setSaving(false);
    }
  };

  return (
    <div className="flex flex-col">
      <PageHeader title="Submit a Project" back />
      <form onSubmit={submit} className="flex flex-col gap-5 px-5 pt-4 pb-8">
        <label className="card flex aspect-video cursor-pointer flex-col items-center justify-center gap-2 overflow-hidden text-text-secondary">
          {preview ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={preview} alt="Cover preview" className="h-full w-full object-cover" />
          ) : (
            <>
              <ImagePlus size={36} className="text-accent" aria-hidden />
              <span className="text-sm">Add a cover image (optional)</span>
            </>
          )}
          <input
            type="file"
            accept="image/*"
            className="sr-only"
            onChange={(e) => {
              const file = e.target.files?.[0] ?? null;
              setImage(file);
              setPreview(file ? URL.createObjectURL(file) : null);
            }}
          />
        </label>
        <div>
          <label htmlFor="p-title" className="label">Project title</label>
          <input id="p-title" className="input" maxLength={120} value={title} onChange={(e) => setTitle(e.target.value)} required />
        </div>
        <div>
          <label htmlFor="p-desc" className="label">Description</label>
          <textarea id="p-desc" className="input" rows={6} maxLength={2000} value={description} onChange={(e) => setDescription(e.target.value)} placeholder="What does it do, how is it built, what did you learn?" required />
        </div>
        <div>
          <label htmlFor="p-tech" className="label">Tech stack</label>
          <input id="p-tech" className="input" value={techStack} onChange={(e) => setTechStack(e.target.value)} placeholder="Comma separated, e.g. PyTorch, Flutter, Firebase" required />
        </div>
        <div>
          <label htmlFor="p-repo" className="label">Repository / demo link (optional)</label>
          <input id="p-repo" type="url" className="input" value={repoUrl} onChange={(e) => setRepoUrl(e.target.value)} placeholder="https://github.com/..." />
        </div>
        <label className="flex items-center gap-3 text-sm font-medium text-text-primary">
          <input type="checkbox" className="h-4 w-4 accent-secondary" checked={teammate} onChange={(e) => setTeammate(e.target.checked)} />
          Looking for teammates
        </label>
        <ErrorText message={error} />
        <button type="submit" className="btn-primary w-full py-3" disabled={saving}>
          {saving ? "Submitting…" : "Submit project"}
        </button>
      </form>
    </div>
  );
}
