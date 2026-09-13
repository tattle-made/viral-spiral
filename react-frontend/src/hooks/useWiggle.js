import { useState, useEffect, useRef } from 'react'
import { playScoreChange } from '../audio'

export function useWiggle(value) {
  const [wiggling, setWiggling] = useState(false)
  const prevRef = useRef(value)
  const timerRef = useRef(null)

  useEffect(() => {
    if (prevRef.current !== value) {
      prevRef.current = value
      clearTimeout(timerRef.current)
      setWiggling(true)
      playScoreChange()
      timerRef.current = setTimeout(() => setWiggling(false), 450)
    }
    return () => clearTimeout(timerRef.current)
  }, [value])

  return wiggling ? 'animate-wiggle' : ''
}
