import { useState } from 'react'

export default function CancelModal({ power, me, onSubmit, onClose }) {
  const [selectedAffinity, setSelectedAffinity] = useState('')
  const [selectedTarget, setSelectedTarget] = useState('')

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60" onClick={onClose}>
      <div className="bg-gray-900 border-2 border-red-500 rounded-xl p-6 max-w-sm w-full mx-4" onClick={e => e.stopPropagation()}>
        <h3 className="text-white font-bold text-lg mb-4">Cancel a Player</h3>

        <div className="mb-3">
          <label className="text-gray-300 text-sm block mb-1">Choose affinity</label>
          <select
            className="w-full bg-gray-800 text-white rounded px-3 py-2 border border-gray-600"
            value={selectedAffinity}
            onChange={e => setSelectedAffinity(e.target.value)}
          >
            <option value="">Select...</option>
            {power.affinity_options?.map(opt => (
              <option key={opt.value} value={opt.value}>{opt.label} ({opt.polarity})</option>
            ))}
          </select>
        </div>

        <div className="mb-4">
          <label className="text-gray-300 text-sm block mb-1">Choose target</label>
          <select
            className="w-full bg-gray-800 text-white rounded px-3 py-2 border border-gray-600"
            value={selectedTarget}
            onChange={e => setSelectedTarget(e.target.value)}
          >
            <option value="">Select...</option>
            {power.target_options?.map(opt => (
              <option key={opt.value} value={opt.value}>{opt.label}</option>
            ))}
          </select>
        </div>

        <div className="flex gap-2">
          <button
            disabled={!selectedAffinity || !selectedTarget}
            onClick={() => onSubmit(selectedAffinity, selectedTarget)}
            className="flex-1 bg-red-700 hover:bg-red-500 text-white py-2 rounded-md disabled:opacity-50"
          >
            Confirm
          </button>
          <button onClick={onClose} className="flex-1 bg-gray-700 hover:bg-gray-600 text-white py-2 rounded-md">
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
