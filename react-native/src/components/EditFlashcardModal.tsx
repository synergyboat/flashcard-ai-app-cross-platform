import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TextInput,
  TouchableOpacity,
  Alert,
  Pressable,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import GradientButton from './GradientButton';
import { Flashcard } from '../types';
import { COLORS, TYPOGRAPHY } from '../config/theme.config';

interface EditFlashcardModalProps {
  visible: boolean;
  flashcard: Flashcard | null;
  onClose: () => void;
  onSave: (flashcard: Flashcard) => void;
  onDelete: (flashcard: Flashcard) => void;
}

const EditFlashcardModal: React.FC<EditFlashcardModalProps> = ({
  visible,
  flashcard,
  onClose,
  onSave,
  onDelete,
}) => {
  const [question, setQuestion] = useState('');
  const [answer, setAnswer] = useState('');

  useEffect(() => {
    if (flashcard) {
      setQuestion(flashcard.question);
      setAnswer(flashcard.answer);
    }
  }, [flashcard]);

  const handleSave = () => {
    if (!flashcard) return;
    
    if (!question.trim() || !answer.trim()) {
      Alert.alert('Error', 'Please fill in both question and answer');
      return;
    }

    const updatedFlashcard: Flashcard = {
      ...flashcard,
      question: question.trim(),
      answer: answer.trim(),
    };

    onSave(updatedFlashcard);
    onClose();
  };

  const handleDelete = () => {
    if (!flashcard) return;
    
    Alert.alert(
      'Confirm Deletion',
      'This action cannot be undone.\n\nAre you sure you want to delete this flashcard?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Confirm',
          style: 'destructive',
          onPress: () => {
            onDelete(flashcard);
            onClose();
          },
        },
      ]
    );
  };

  if (!flashcard) return null;

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent={true}
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <Pressable
          style={styles.backdrop}
          onPress={onClose}
          accessibilityRole="button"
          accessibilityLabel="Close edit modal"
        />
        <View style={styles.modalContent}>
          <View style={styles.handle} />
          
          <View style={styles.header}>
            <Text style={styles.title}>Edit Flashcard</Text>
            <TouchableOpacity onPress={handleDelete}>
              <Text style={styles.deleteText}>Delete</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.inputContainer}>
            <Text style={styles.label}>Question</Text>
            <TextInput
              style={styles.textInput}
              value={question}
              onChangeText={setQuestion}
              placeholder="Enter question"
              placeholderTextColor={COLORS.TEXT.LIGHT}
              multiline
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={styles.label}>Answer</Text>
            <TextInput
              style={styles.textInput}
              value={answer}
              onChangeText={setAnswer}
              placeholder="Enter answer"
              placeholderTextColor={COLORS.TEXT.LIGHT}
              multiline
            />
          </View>

          <GradientButton
            title="✓ Save changes"
            onPress={handleSave}
            style={styles.saveButton}
          />
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    justifyContent: 'flex-end',
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalContent: {
    backgroundColor: COLORS.BACKGROUND.CARD,
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    padding: 20,
    paddingBottom: 40,
    minHeight: '50%',
  },
  handle: {
    width: 40,
    height: 4,
    backgroundColor: COLORS.BORDER.LIGHT,
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: TYPOGRAPHY.SIZES.LARGE,
    fontWeight: TYPOGRAPHY.WEIGHTS.BOLD,
    color: COLORS.TEXT.PRIMARY,
  },
  deleteText: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.STATUS.ERROR,
    fontWeight: TYPOGRAPHY.WEIGHTS.NORMAL,
  },
  inputContainer: {
    marginBottom: 16,
  },
  label: {
    fontSize: TYPOGRAPHY.SIZES.SMALL,
    color: COLORS.TEXT.PRIMARY,
    marginBottom: 8,
    fontWeight: TYPOGRAPHY.WEIGHTS.NORMAL,
  },
  textInput: {
    borderWidth: 1,
    borderColor: COLORS.BORDER.LIGHT,
    borderRadius: 8,
    padding: 12,
    fontSize: TYPOGRAPHY.SIZES.MEDIUM,
    color: COLORS.TEXT.PRIMARY,
    backgroundColor: COLORS.BACKGROUND.CARD,
    minHeight: 80,
    textAlignVertical: 'top',
  },
  saveButton: {
    marginTop: 16,
  },
});

export default EditFlashcardModal;