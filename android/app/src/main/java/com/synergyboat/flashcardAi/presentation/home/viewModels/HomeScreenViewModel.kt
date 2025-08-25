package com.synergyboat.flashcardAi.presentation.home.viewModels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.synergyboat.flashcardAi.domain.entities.Deck
import com.synergyboat.flashcardAi.domain.repository.FlashcardRepository
import com.synergyboat.flashcardAi.domain.usecase.deck.CreateMultipleFlashcardsToDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.CreateNewDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.DeleteDeckUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.GetAllDecksUseCase
import com.synergyboat.flashcardAi.domain.usecase.deck.UpdateDeckDetailsUseCase
import com.synergyboat.flashcardAi.domain.usecase.flashcard.DeleteFlashcardUseCase
import com.synergyboat.flashcardAi.domain.usecase.flashcard.GetFlashcardsFromDeckUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import javax.inject.Inject
import kotlin.coroutines.cancellation.CancellationException
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.logging.Logger
import kotlin.system.measureTimeMillis

@HiltViewModel
class HomeScreenViewModel @Inject constructor(
    private val getAllDecksUseCase: GetAllDecksUseCase,
    private val deleteDeckUseCase: DeleteDeckUseCase,
    private val updateDeckDetailsUseCase: UpdateDeckDetailsUseCase,

    //------------------------

    private val createNewDeckUseCase: CreateNewDeckUseCase,
    private val createMultipleFlashcardsToDeckUseCase: CreateMultipleFlashcardsToDeckUseCase,
    private val deleteFlashcardUseCase: DeleteFlashcardUseCase,
    private val getFlashcardsFromDeckUseCase: GetFlashcardsFromDeckUseCase,
    private val updateFlashcardRepository: FlashcardRepository,
) : ViewModel() {
    // This ViewModel can be used to manage the state and logic for the Home Screen.
    // You can add LiveData or StateFlow properties here to hold the UI state.
    // Additionally, you can inject use cases or repositories as needed for data operations.

    // Example:
    // private val _decks = MutableLiveData<List<Deck>>()
    // val decks: LiveData<List<Deck>> get() = _decks
    // // fun loadDecks() {
    //     viewModelScope.launch {
    //         _decks.value = deckRepository.getAllDecks()
    //     }
    // }

    private val _decks = MutableStateFlow<List<Deck>>(emptyList())
    private val _isLoading = MutableStateFlow(true)
    val decks: StateFlow<List<Deck>> = _decks
    val isLoading: StateFlow<Boolean> = _isLoading

    private var refreshJob: Job? = null

    fun refreshDecks() {
        refreshJob?.cancel()
        refreshJob = viewModelScope.launch {
            setIsLoading(true)
            try {
                // Keep heavy I/O off the main thread
                val decks = withContext(Dispatchers.IO) { getAllDecksUseCase() }
                _decks.value = decks
            } catch (ce: CancellationException) {
                throw ce
            } catch (e: Exception) {
                e.printStackTrace() //Log the exception and report in production
            } finally {
                setIsLoading(false)
            }
        }
    }

    fun setIsLoading(state: Boolean) {
        _isLoading.value = state
    }

    fun updateDeck(updatedDeck: Deck) {
        viewModelScope.launch {
            updateDeckDetailsUseCase(updatedDeck)
            refreshDecks()
        }
    }

    fun deleteDeck(deck: Deck) {
        viewModelScope.launch {
            deleteDeckUseCase(deck)
            refreshDecks()
        }
    }

    private data class DatabaseBenchmarkRow(
        val iteration: Int,
        val dbRowSizeAddDemoDeck: Int,
        val dbWriteAddDemoDeck: Double,
        val dbRowSizeAddDemoFlashcard: Int,
        val dbWriteAddDemoFlashcard: Double,
        val dbReadFetchDemoDeck: Double,
        val dbRowSizeFetchedDemoDeck: Int,
        val dbReadFetchDemoFlashcards: Double,
        val dbRowSizeFetchedDemoFlashcards: Int,
        val dbRead: Double,
        val dbReadGetAllDecksWithFlashcards: Double,
        val dbRowSizeGetAllDecksWithFlashcards: Int
    ) {
        fun toCsv(): String = listOf(
            iteration,
            dbRowSizeAddDemoDeck,
            "%.2f".format(dbWriteAddDemoDeck),
            dbRowSizeAddDemoFlashcard,
            "%.2f".format(dbWriteAddDemoFlashcard),
            "%.2f".format(dbReadFetchDemoDeck),
            dbRowSizeFetchedDemoDeck,
            "%.2f".format(dbReadFetchDemoFlashcards),
            dbRowSizeFetchedDemoFlashcards,
            "%.2f".format(dbRead),
            "%.2f".format(dbReadGetAllDecksWithFlashcards),
            dbRowSizeGetAllDecksWithFlashcards
        ).joinToString(",")

        companion object {
            fun header(): String = listOf(
                "Iteration",
                "db_row_size_add_demo_Deck (B)",
                "db_write_add_demo_deck (ms)",
                "db_row_size_add_demo_flashcard (B)",
                "db_write_add_demo_flashcard (ms)",
                "db_read_fetch_demo_deck (ms)",
                "db_row_size_fetched_demo_deck (B)",
                "db_read_fetch_demo_flashcards (ms)",
                "db_row_size_fetched_demo_flashcards (B)",
                "db_read (ms)",
                "db_read_getAllDecksWithFlashcards (ms)",
                "db_row_size_getAllDecksWithFlashcards (B)"
            ).joinToString(",")
        }
    }

    /** Chunked logging to avoid truncation. */
    private fun Logger.logInChunks(tag: String, message: String, chunkSize: Int = 800) {
        var i = 0
        while (i < message.length) {
            val end = (i + chunkSize).coerceAtMost(message.length)
            this.info("$tag [${i / chunkSize}] ${message.substring(i, end)}")
            i = end
        }
    }

    /** Safer size helper that prefers your RowSizeBenchmark. */
    private fun sizeBytesSafe(any: Any): Int = try {
        // Replace the package if your helper lives elsewhere:
        com.synergyboat.flashcardAi.core.benchmark.RowSizeBenchmark.getRowSizeInBytes(any)
    } catch (_: Throwable) {
        any.toString().encodeToByteArray().size
    }

    /**
     * Run DB benchmark from the ViewModel (no reflection).
     * Mirrors the Flutter phases & CSV format exactly.
     */
    fun runDatabaseBenchmark(
        iterations: Int = 1,
        logger: Logger = Logger.getLogger("db_benchmark")
    ) {
        viewModelScope.launch {
            val rows = mutableListOf<DatabaseBenchmarkRow>()

            withContext(Dispatchers.IO) {
                repeat(iterations) { idx ->
                    // ---------------- 1) Add Demo Deck ----------------
                    val demoDeck = Deck(
                        name = "Benchmark Deck",
                        description = "A deck for benchmarking purposes"
                    )
                    val dbRowSizeAddDemoDeck = sizeBytesSafe(demoDeck)

                    var createdResult: Any? = null
                    val tAddDeckMs = measureTimeMillis {
                        createdResult = createNewDeckUseCase(demoDeck)
                    }.toDouble()

                    // Resolve deckId & Deck object (supports either Long or Deck return)
                    val createdDeckId: Long = when (val r = createdResult) {
                        is Long -> r
                        is Deck -> r.id ?: run {
                            // fallback: find by content if id wasn’t assigned yet
                            getAllDecksUseCase().firstOrNull {
                                it.name == demoDeck.name && it.description == demoDeck.description
                            }?.id ?: error("Deck id not found after creation")
                        }
                        else -> {
                            // fallback attempt
                            getAllDecksUseCase().firstOrNull {
                                it.name == demoDeck.name && it.description == demoDeck.description
                            }?.id ?: error("Unsupported CreateNewDeckUseCase return type")
                        }
                    }

                    // Fetch created deck object (for size & cleanup)
                    val tFetchDeckMs = measureTimeMillis {
                        getAllDecksUseCase()
                    }.toDouble()
                    val deckFetched: Deck? = getAllDecksUseCase().firstOrNull { it.id == createdDeckId }
                    val dbRowSizeFetchedDemoDeck = deckFetched?.let { sizeBytesSafe(it) } ?: 0

                    // ---------------- 2) Add Demo Flashcard ----------------
                    val demoFlashcard = com.synergyboat.flashcardAi.domain.entities.Flashcard(
                        question = "What is the capital of Germany?",
                        answer = "Berlin",
                        deckId = createdDeckId
                    )
                    val dbRowSizeAddDemoFlashcard = sizeBytesSafe(demoFlashcard)

                    val tAddFlashcardMs = measureTimeMillis {
                        createMultipleFlashcardsToDeckUseCase(listOf(demoFlashcard))
                    }.toDouble()

                    // ---------------- 3) Fetch Flashcards by DeckId ----------------
                    var fetchedFlashcards: List<com.synergyboat.flashcardAi.domain.entities.Flashcard> = emptyList()
                    val tFetchFlashcardsMs = measureTimeMillis {
                        fetchedFlashcards = getFlashcardsFromDeckUseCase(createdDeckId)
                    }.toDouble()
                    val dbRowSizeFetchedDemoFlashcards = sizeBytesSafe(fetchedFlashcards)

                    // ---------------- 4) General read (all decks) ----------------
                    val tReadAllMs = measureTimeMillis {
                        getAllDecksUseCase()
                    }.toDouble()

                    // ---------------- 5) All decks with flashcards ----------------
                    var decksWithFlashcardsPayloadSize = 0
                    val tReadAllWithFlashcardsMs = measureTimeMillis {
                        val allDecks = getAllDecksUseCase()
                        val joined = allDecks.map { d ->
                            val fcs = getFlashcardsFromDeckUseCase(d.id ?: -1L)
                            mapOf("deck" to d, "flashcards" to fcs)
                        }
                        decksWithFlashcardsPayloadSize = sizeBytesSafe(joined)
                    }.toDouble()

                    // ---------------- 6) Cleanup ----------------
                    try {
                        deckFetched?.let { deleteDeckUseCase(it) }
                    } catch (t: Throwable) {
                        logger.warning("db_cleanup_delete_deck | ${t.message}")
                    }

                    rows += DatabaseBenchmarkRow(
                        iteration = idx + 1,
                        dbRowSizeAddDemoDeck = dbRowSizeAddDemoDeck,
                        dbWriteAddDemoDeck = tAddDeckMs,
                        dbRowSizeAddDemoFlashcard = dbRowSizeAddDemoFlashcard,
                        dbWriteAddDemoFlashcard = tAddFlashcardMs,
                        dbReadFetchDemoDeck = tFetchDeckMs,
                        dbRowSizeFetchedDemoDeck = dbRowSizeFetchedDemoDeck,
                        dbReadFetchDemoFlashcards = tFetchFlashcardsMs,
                        dbRowSizeFetchedDemoFlashcards = dbRowSizeFetchedDemoFlashcards,
                        dbRead = tReadAllMs,
                        dbReadGetAllDecksWithFlashcards = tReadAllWithFlashcardsMs,
                        dbRowSizeGetAllDecksWithFlashcards = decksWithFlashcardsPayloadSize
                    )
                }
            }

            // CSV output (same as Flutter)
            logger.logInChunks(tag = "NATIVE_DB", message = DatabaseBenchmarkRow.header())
            rows.forEach { logger.logInChunks(tag = "NATIVE_DB", message = it.toCsv()) }
        }
    }
}