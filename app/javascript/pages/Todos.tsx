import { FormEvent, KeyboardEvent, useState } from "react"
import { Head, router, useForm, usePage } from "@inertiajs/react"
import { AppShell } from "@/components/AppShell"
import { PageHeader } from "@/components/PageHeader"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Checkbox } from "@/components/ui/checkbox"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"

import type { PageProps } from "@/types/inertia"

type Todo = { id: number; description: string; completed: boolean }

const DESCRIPTION = "Your personal to-do list: add items, check them off, edit them, and delete them."

function TodoRow({ todo }: { todo: Todo }) {
  const [editing, setEditing] = useState(false)
  const [draft, setDraft] = useState(todo.description)
  const [confirmingDelete, setConfirmingDelete] = useState(false)
  const { props } = usePage<PageProps>()
  const [editError, setEditError] = useState(false)
  const error = editing && editError ? props.errors?.description : undefined

  const toggle = () =>
    router.patch(`/todos/${todo.id}`, { completed: !todo.completed }, { preserveScroll: true })

  const startEdit = () => {
    setDraft(todo.description)
    setEditError(false)
    setEditing(true)
  }

  const cancelEdit = () => {
    setEditing(false)
    setEditError(false)
  }

  const save = () => {
    setEditError(true)
    router.patch(
      `/todos/${todo.id}`,
      { description: draft },
      {
        preserveScroll: true,
        onSuccess: (page) => {
          if (!page.props.errors?.description) setEditing(false)
        },
      },
    )
  }

  const onKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      e.preventDefault()
      save()
    } else if (e.key === "Escape") {
      cancelEdit()
    }
  }

  const remove = () =>
    router.delete(`/todos/${todo.id}`, {
      preserveScroll: true,
      onSuccess: () => setConfirmingDelete(false),
    })

  return (
    <li className="flex items-start gap-3 border-b border-hairline py-3">
      <Checkbox
        className="mt-1.5"
        checked={todo.completed}
        onChange={toggle}
        aria-label={`Mark "${todo.description}" as ${todo.completed ? "incomplete" : "complete"}`}
      />
      <div className="min-w-0 flex-1">
        {editing ? (
          <div className="space-y-2">
            <Input
              autoFocus
              aria-label="Edit description"
              aria-invalid={!!error}
              value={draft}
              onChange={(e) => setDraft(e.target.value)}
              onKeyDown={onKeyDown}
            />
            {error && <p className="text-xs text-danger-display">{error}</p>}
            <div className="flex gap-2">
              <Button size="sm" onClick={save}>Save</Button>
              <Button size="sm" variant="ghost" onClick={cancelEdit}>Cancel</Button>
            </div>
          </div>
        ) : (
          <p className={todo.completed ? "line-through opacity-60" : undefined}>
            {todo.description}
          </p>
        )}
      </div>
      <Badge tone={todo.completed ? "accent" : "muted"}>
        {todo.completed ? "Completed" : "Incomplete"}
      </Badge>
      {!editing && (
        <div className="flex gap-1">
          <Button size="sm" variant="ghost" onClick={startEdit}>Edit</Button>
          <Button size="sm" variant="ghost" onClick={() => setConfirmingDelete(true)}>Delete</Button>
        </div>
      )}
      <Dialog open={confirmingDelete} onOpenChange={setConfirmingDelete}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Delete to-do?</DialogTitle>
            <DialogDescription>
              "{todo.description}" will be permanently deleted.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <DialogClose asChild>
              <Button variant="secondary">Cancel</Button>
            </DialogClose>
            <Button variant="danger" onClick={remove}>Delete</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </li>
  )
}

function TodoSection({ title, empty, todos }: { title: string; empty: string; todos: Todo[] }) {
  return (
    <section aria-label={title} className="mt-8">
      <h2>
        {title} ({todos.length})
      </h2>
      {todos.length === 0 ? (
        <p className="mt-2">{empty}</p>
      ) : (
        <ul className="mt-2 list-none p-0">
          {todos.map((todo) => (
            <TodoRow key={todo.id} todo={todo} />
          ))}
        </ul>
      )}
    </section>
  )
}

export default function Todos({ todos }: { todos: Todo[] }) {
  const { props } = usePage<PageProps>()
  const form = useForm({ description: "" })
  const pending = todos.filter((t) => !t.completed)
  const completed = todos.filter((t) => t.completed)
  const createError = form.wasSuccessful ? undefined : props.errors?.description

  const submit = (e: FormEvent) => {
    e.preventDefault()
    form.post("/todos", { preserveScroll: true, onSuccess: () => form.reset() })
  }

  return (
    <>
      <Head title="My to-dos">
        <meta name="description" content={DESCRIPTION} />
        <meta property="og:title" content="My to-dos" />
        <meta property="og:description" content={DESCRIPTION} />
      </Head>
      <AppShell>
        <PageHeader title="To-dos" description="Keep track of what you need to get done." />

        <section className="mt-8 max-w-2xl">
          <form onSubmit={submit} className="flex items-start gap-2">
            <div className="flex-1 space-y-2">
              <label htmlFor="new-todo" className="sr-only">New to-do</label>
              <Input
                id="new-todo"
                placeholder="What needs to be done?"
                aria-invalid={!!createError}
                value={form.data.description}
                onChange={(e) => form.setData("description", e.target.value)}
              />
              {createError && <p className="text-xs text-danger-display">{createError}</p>}
            </div>
            <Button type="submit" disabled={form.processing}>Add</Button>
          </form>

          {todos.length === 0 ? (
            <p className="mt-8">Nothing here yet. Add your first to-do above.</p>
          ) : (
            <>
              <TodoSection title="Pending" empty="Nothing pending. Nice work!" todos={pending} />
              <TodoSection title="Completed" empty="Nothing completed yet." todos={completed} />
            </>
          )}
        </section>
      </AppShell>
    </>
  )
}
